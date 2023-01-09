import os
import logging
import json

from flask_appbuilder.security.manager import AUTH_OAUTH
from airflow.www.security import AirflowSecurityManager

basedir = os.path.abspath(os.path.dirname(__file__))
logger = logging.getLogger(__name__)

AUTH_TYPE = AUTH_OAUTH
AUTH_ROLE_ADMIN = 'Admin'
AUTH_USER_REGISTRATION = True
AUTH_USER_REGISTRATION_ROLE = 'Public'
AUTH_ROLES_SYNC_AT_LOGIN = True

OAUTH_PROVIDERS = []
DEX_PROVIDER_FILE = 'dex_provider_cfg.json'

AUTH_ROLES_MAPPING_FILE = 'auth_roles_mapping.json'
with open(AUTH_ROLES_MAPPING_FILE) as f:
    AUTH_ROLES_MAPPING = json.loads(f.read())

with open(DEX_PROVIDER_FILE) as f:
    DEX_PROVIDER = json.loads(f.read())

OAUTH_PROVIDERS.append(DEX_PROVIDER)

class CustomSsoSecurityManager(AirflowSecurityManager):

    def oauth_user_info(self, provider, response=None):
        logging.debug("Oauth2 provider: {0}.".format(provider))
        if provider == 'dex':
            # As example, this line request a GET to base_url + '/' + userDetails with Bearer  Authentication,
            # and expects that authorization server checks the token, and response with user details
            me = self.appbuilder.sm.oauth_remotes[provider].get('userinfo')
            logging.debug("response: {0}".format(me))
            me = me.json()
            logging.info("User {0} logging in. Groups: {1}".format(me['email'], me.get("groups", [])))
            return {
                'name': me['email'],
                'email': me['email'],
                'id': me['email'],
                'username': me['email'],
                'first_name': '',
                'last_name': '',
                "role_keys": me.get("groups", []),
            }


SECURITY_MANAGER_CLASS = CustomSsoSecurityManager
