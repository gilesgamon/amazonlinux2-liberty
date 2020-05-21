# amazonlinux2-liberty
IBM Liberty build on AmazonLinux2

Builds a (set of) container which ultimately provide an example ferret app - thsi part would obviously be wswitched out for something more useful.

The core ideas are taken from IBM's AWS quick start: https://github.com/aws-quickstart/quickstart-ibm-websphere-liberty

However, uses Centos7 in the form of amazonlinux:2 and builds out logical (to me) layers in dockerfiles.

Adds supervisord to take care of daemon type running, given systemctl relies on D-Bus - which doesn't work in docker really.

Also adds in AWS CloudWatch agent to push logs from inside the container to AWS CW. That needs a bit more testing.

##To Do

Add variant of more up-to-date binaries.
Wrap and test for Fargate.
Perhaps switch from SDK to JDK - minor me thinks
Tune the logs - I prep'd amazon-cloudwatch-agent.json but have not yet put it all together in the supervisord orchestrated method yet 