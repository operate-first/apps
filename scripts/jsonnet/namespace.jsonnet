local namespace = std.extVar('NAMESPACE');
local requester = std.extVar('REQUESTER');
local display_name = std.extVar('DISPLAY_NAME');
local project_owner = std.extVar('PROJECT_OWNER');
local onboarding_issue = std.extVar('ONBOARDING_ISSUE');
local docs = std.extVar('DOCS');

{
  apiVersion: "v1",
  kind: "Namespace",
  metadata: {
    name: namespace,
    annotations: {
      'openshift.io/requester': requester,
      'openshift.io/display-name': display_name,
      'op1st/project-owner': project_owner,
      'op1st/onboarding-issue': onboarding_issue,
      'op1st/docs': docs,
    }
  }
}
