import os
from flask_appbuilder.security.manager import AUTH_OAUTH

MAPBOX_API_KEY = os.getenv('MAPBOX_API_KEY', '')
SQLALCHEMY_DATABASE_URI = "postgresql://{}:{}@supersetdb:5432/{}".format(os.environ['POSTGRESQL_USERNAME'], os.environ['POSTGRESQL_PASSWORD'], os.environ['POSTGRESQL_DATABASE'])
SQLALCHEMY_TRACK_MODIFICATIONS = True
SECRET_KEY = os.getenv('SUPERSET_SECRET_KEY', '$(SUPERSET_SECRET_KEY)')
DATA_DIR = '/var/lib/superset'
LOG_LEVEL = 'INFO'
FEATURE_FLAGS = {
    'ENABLE_TEMPLATE_PROCESSING': True,
}

AUTH_TYPE = AUTH_OAUTH
AUTH_USER_REGISTRATION = True
AUTH_USER_REGISTRATION_ROLE = "Public"

# maps OCP groups (retrieved from role_keys) to Superset roles
# NOTE: A user can not have a role mapped to them twice
# Thi will result in a SQL INSERT constraint violation in postgres
AUTH_ROLES_MAPPING = {
    "odh-admin": ["Admin"],
    "superset-admins": ["Admin"],
    "superset-user": ["Alpha"],
}
# if we should replace ALL the user's roles each login, or only on registration
AUTH_ROLES_SYNC_AT_LOGIN = True

# force users to re-auth after 30min of inactivity (to keep roles in sync)
PERMANENT_SESSION_LIFETIME = 1800
OAUTH_PROVIDERS = [
    {'name': 'dex',
     'token_key': 'access_token',
     'icon': 'fa-github',
     'remote_app': {
         'client_id': 'superset',
         'client_secret': SECRET_KEY,
         'client_kwargs': {
             'scope': 'openid email groups profile offline_access'
         },
         'api_base_url': 'https://dex-dex.apps.smaug.na.operate-first.cloud/userinfo',
         'access_token_url': 'https://dex-dex.apps.smaug.na.operate-first.cloud/token',
         'authorize_url': 'https://dex-dex.apps.smaug.na.operate-first.cloud/auth'
     }
     }
]

WTF_CSRF_ENABLED = False

from custom_sso_security_manager import CustomSsoSecurityManager
CUSTOM_SECURITY_MANAGER = CustomSsoSecurityManager
