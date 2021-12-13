# Getting started with Operate First

If you are an open source developer interested in bringing your project to an Operate First environment, you have come to the right place.
Below is important information and instructions on how to get started.

## There are 3 parts to Operating First

1. Operate First is a concept of bringing pre-release open source software to a production cloud environment.

2. The Open Infrastructure Labs is the upstream where the cloud operators and project developers work in the open to Operate First.

3. The Mass Open Cloud (MOC) is a production cloud resource where projects are run.

## Observing and interacting with the Ops team

Projects are expected to work with the ops team in the open in github https://github.com/operate-first
There is also work done to manage the infrastructure that can be found in the Open Infrastructure Labs project https://github.com/open-infrastructure-labs

To see what’s happening right now, online chat is done at http://operatefirst.slack.com/.
There is an associated mailing list hosted by the MOC: Operate-first-users https://mail.massopen.cloud/mailman/listinfo/operate-first-users

Open Infrastructure Labs also has a mailing list: Openinfralabs http://lists.opendev.org/cgi-bin/mailman/listinfo/openinfralabs
You can view a dashboard in the OI Labs github to see an overview of what’s happening https://github.com/orgs/open-infrastructure-labs/projects/2


## Bring your project

To get connected and investigate bringing your project to the MOC, you can join the general mailing list at https://lists.operate-first.cloud/archives/list/community@lists.operate-first.cloud/ and introduce it.

Next step is bringing the discussion to the “Operate First Project Coordination meeting”, which is held on alternate Wednesday’s 8:30AM US Eastern time. (even numbered weeks for 2020) Meeting url: https://meet.google.com/kea-qtds-enp?authuser=0&hs=122. (email bburns@redhat.com for an invite).

There is another bi-weekly meeting an the alternate Wednesdays at 8:30 AM US Eastern time, called “MOC/ODH sprint planning” and it is primarily focused on the Ops team planning. (Odd numbered weeks for 2021) Meeting url: https://meet.google.com/oki-drge-wuc?authuser=0&hs=122

More detailed information on onboarding to a cluster can be found here: https://www.operate-first.cloud/apps/content/cluster-scope/onboarding_to_cluster.html


## Understanding the environment

There are a few basic things that need to be understood about the Operate First environment at the MOC:

- Operate First is an open source initiative. It’s about operating your project software in the open in a production cloud environment.

- Operating at the MOC never implies that any feature or software will ship. Thus a new feature that is being considered can be tested without any implied commitment.

- Open Infrastructure Labs is an open source upstream aimed at cloud providers and operators and that is where much of the operate first work is being done.

- While a production cloud, the MOC is taking in pre-release software, and thus stability is not guaranteed, and should not be expected. No backup of user data is made. There is no SLA.

- It’s free, but the cost is commitment. The MOC is not a place to bring a project and then leave. It’s expected that the developers will actively participate with the operators when needed and be available to help sort out issues.

- The benefit to project developers is bringing back what’s learned to improve their project.

- Also, projects need to agree that telemetry can be freely harvested from the cloud. It’s purpose is to help evolve open source cloud operations and it extends to building AI Ops tooling.
