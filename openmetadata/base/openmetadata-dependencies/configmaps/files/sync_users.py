############################
#### BEGIN: GLOBAL CODE ####
############################
####################
## Global Imports ##
####################
import logging
import os
import time
from string import Template
from typing import List, Dict, Optional


####################
## Global Configs ##
####################
# the path which Secret/ConfigMap are mounted to
CONF__TEMPLATES_PATH = "/mnt/templates"

# how frequently to check for Secret/ConfigMap updates
CONF__TEMPLATES_SYNC_INTERVAL = 10

# how frequently to re-sync objects (Connections, Pools, Users, Variables)
CONF__OBJECTS_SYNC_INTERVAL = 60


######################
## Global Functions ##
######################
def string_substitution(raw_string: Optional[str], substitution_map: Dict[str, str]) -> str:
    """
    Apply bash-like substitutions to a raw string.

    Example:
    - string_substitution("Hello!", None) -> "Hello!"
    - string_substitution("Hello ${NAME}!", {"NAME": "Airflow"}) -> "Hello Airflow!"
    """
    if raw_string and len(substitution_map) > 0:
        tpl = Template(raw_string)
        return tpl.safe_substitute(substitution_map)
    else:
        return raw_string


def template_mtime(template_name: str) -> float:
    """
    Return the modification-time of the file storing `template_name`
    """
    file_path = f"{CONF__TEMPLATES_PATH}/{template_name}"
    return os.stat(file_path).st_mtime


def template_value(template_name: str) -> str:
    """
    Return the contents of the file storing `template_name`
    """
    file_path = f"{CONF__TEMPLATES_PATH}/{template_name}"
    with open(file_path, "r") as f:
        return f.read()


def refresh_template_cache(template_names: List[str],
                           template_mtime_cache: Dict[str, float],
                           template_value_cache: Dict[str, str]) -> List[str]:
    """
    Refresh the provided dictionary caches of template values & mtimes.

    :param template_names: the names of all templates to refresh
    :param template_mtime_cache: the dictionary cache of template file modification-times
    :param template_value_cache: the dictionary cache of template values
    :return: the names of templates which changed
    """
    changed_templates = []
    for template_name in template_names:
        old_mtime = template_mtime_cache.get(template_name, None)
        new_mtime = template_mtime(template_name)
        # first, check if the files were modified
        if old_mtime != new_mtime:
            old_value = template_value_cache.get(template_name, None)
            new_value = template_value(template_name)
            # second, check if the value actually changed
            if old_value != new_value:
                template_value_cache[template_name] = new_value
                changed_templates += [template_name]
            template_mtime_cache[template_name] = new_mtime
    return changed_templates


def main(sync_forever: bool):
    # initial sync of template cache
    refresh_template_cache(
        template_names=VAR__TEMPLATE_NAMES,
        template_mtime_cache=VAR__TEMPLATE_MTIME_CACHE,
        template_value_cache=VAR__TEMPLATE_VALUE_CACHE
    )

    # initial sync of objects into Airflow DB
    sync_with_airflow()

    if sync_forever:
        # define variables used to track how long since last refresh/sync
        templates_sync_epoch = time.time()
        objects_sync_epoch = time.time()

        # main loop
        while True:
            # monitor for template secret/configmap updates
            if (time.time() - templates_sync_epoch) > CONF__TEMPLATES_SYNC_INTERVAL:
                logging.debug(f"template sync interval reached, re-syncing all templates...")
                changed_templates = refresh_template_cache(
                    template_names=VAR__TEMPLATE_NAMES,
                    template_mtime_cache=VAR__TEMPLATE_MTIME_CACHE,
                    template_value_cache=VAR__TEMPLATE_VALUE_CACHE
                )
                templates_sync_epoch = time.time()
                if changed_templates:
                    logging.info(f"template values have changed: [{','.join(changed_templates)}]")
                    sync_with_airflow()
                    objects_sync_epoch = time.time()

            # monitor for external changes to objects (like from UI)
            if (time.time() - objects_sync_epoch) > CONF__OBJECTS_SYNC_INTERVAL:
                logging.debug(f"sync interval reached, re-syncing all objects...")
                sync_with_airflow()
                objects_sync_epoch = time.time()

            # ensure we dont loop too fast
            time.sleep(0.5)
##########################
#### END: GLOBAL CODE ####
##########################


#############
## Imports ##
#############
import sys
from werkzeug.security import check_password_hash, generate_password_hash
import airflow.www.app as www_app
flask_app = www_app.create_app()
flask_appbuilder = flask_app.appbuilder

# airflow uses its own incompatible FAB models in 2.3.0+
try:
    from airflow.www.fab_security.sqla.models import User, Role
except ModuleNotFoundError:
    from flask_appbuilder.security.sqla.models import User, Role


#############
## Classes ##
#############
class UserWrapper(object):
    def __init__(
            self,
            username: str,
            first_name: Optional[str] = None,
            last_name: Optional[str] = None,
            email: Optional[str] = None,
            roles: Optional[List[str]] = None,
            password: Optional[str] = None
    ):
        self.username = username
        self._first_name = first_name
        self._last_name = last_name
        self._email = email
        self.roles = roles
        self._password = password

    @property
    def first_name(self) -> str:
        return string_substitution(self._first_name, VAR__TEMPLATE_VALUE_CACHE)

    @property
    def last_name(self) -> str:
        return string_substitution(self._last_name, VAR__TEMPLATE_VALUE_CACHE)

    @property
    def email(self) -> str:
        return string_substitution(self._email, VAR__TEMPLATE_VALUE_CACHE)

    @property
    def password(self) -> str:
        return string_substitution(self._password, VAR__TEMPLATE_VALUE_CACHE)

    def as_dict(self) -> Dict[str, str]:
        return {
            "username": self.username,
            "first_name": self.first_name,
            "last_name": self.last_name,
            "email": self.email,
            "roles": [find_role(role_name=role_name) for role_name in self.roles],
            "password": self.password
        }


###############
## Variables ##
###############
VAR__TEMPLATE_NAMES = [
]
VAR__TEMPLATE_MTIME_CACHE = {}
VAR__TEMPLATE_VALUE_CACHE = {}
VAR__USER_WRAPPERS = {
    "admin": UserWrapper(
        username=os.getenv('AIRFLOW_USERNAME', 'peterparker'),
        first_name=os.getenv('AIRFLOW_FNAME', 'Peter'),
        last_name=os.getenv('AIRFLOW_LNAME', 'Parker'),
        email=os.getenv('AIRFLOW_EMAIL', 'spiderman@marvel.com'),
        roles=[os.getenv('AIRFLOW_ROLE', 'Admin')],
        password=os.getenv('AIRFLOW_PASSWORD', 'admin')
    ),
}


###############
## Functions ##
###############
def find_role(role_name: str) -> Role:
    """
    Get the FAB Role model associated with a `role_name`.
    """
    found_role = flask_appbuilder.sm.find_role(role_name)
    if found_role:
        return found_role
    else:
        valid_roles = flask_appbuilder.sm.get_all_roles()
        logging.error(f"Failed to find role=`{role_name}`, valid roles are: {valid_roles}")
        sys.exit(1)


def compare_role_lists(role_list_1: List[Role], role_list_2: List[Role]) -> bool:
    """
    Check if two lists of FAB Roles contain the same roles (ignores duplicates and order).
    """
    name_set_1 = set(role.name for role in role_list_1)
    name_set_2 = set(role.name for role in role_list_2)
    return name_set_1 == name_set_2



def compare_users(user_dict: Dict, user_model: User) -> bool:
    """
    Check if user info (stored in dict) is identical to a FAB User model.
    """
    return (
            user_dict["username"] == user_model.username
            and user_dict["first_name"] == user_model.first_name
            and user_dict["last_name"] == user_model.last_name
            and user_dict["email"] == user_model.email
            and compare_role_lists(user_dict["roles"], user_model.roles)
            and check_password_hash(pwhash=user_model.password, password=user_dict["password"])
    )


def sync_user(user_wrapper: UserWrapper) -> None:
    """
    Sync the User defined by a provided UserWrapper into the FAB DB.
    """
    username = user_wrapper.username
    u_new = user_wrapper.as_dict()
    u_old = flask_appbuilder.sm.find_user(username=username)

    if not u_old:
        logging.info(f"User=`{username}` is missing, adding...")
        created_user = flask_appbuilder.sm.add_user(
            username=u_new["username"],
            first_name=u_new["first_name"],
            last_name=u_new["last_name"],
            email=u_new["email"],
            # in old versions of flask_appbuilder `add_user(role=` can only add exactly one role
            # (unchecked 0 index is safe because we require at least one role using helm values validation)
            role=u_new["roles"][0],
            password=u_new["password"]
        )
        if created_user:
            # add the full list of roles (we only added the first one above)
            created_user.roles = u_new["roles"]
            logging.info(f"User=`{username}` was successfully added.")
        else:
            logging.error(f"Failed to add User=`{username}`")
            sys.exit(1)
    else:
        if compare_users(u_new, u_old):
            pass
        else:
            logging.info(f"User=`{username}` exists but has changed, updating...")
            u_old.first_name = u_new["first_name"]
            u_old.last_name = u_new["last_name"]
            u_old.email = u_new["email"]
            u_old.roles = u_new["roles"]
            u_old.password = generate_password_hash(u_new["password"])
            # strange check for False is because update_user() returns None for success
            # but in future might return the User model
            if not (flask_appbuilder.sm.update_user(u_old) is False):
                logging.info(f"User=`{username}` was successfully updated.")
            else:
                logging.error(f"Failed to update User=`{username}`")
                sys.exit(1)


def sync_all_users(user_wrappers: Dict[str, UserWrapper]) -> None:
    """
    Sync all users in provided `user_wrappers`.
    """
    logging.info("BEGIN: airflow users sync")
    for user_wrapper in user_wrappers.values():
        sync_user(user_wrapper)
    logging.info("END: airflow users sync")

    # ensures than any SQLAlchemy sessions are closed (so we don't hold a connection to the database)
    flask_app.do_teardown_appcontext()


def sync_with_airflow() -> None:
    """
    Preform a sync of all objects with airflow (note, `sync_with_airflow()` is called in `main()` template).
    """
    sync_all_users(user_wrappers=VAR__USER_WRAPPERS)


##############
## Run Main ##
##############
main(sync_forever=True)
