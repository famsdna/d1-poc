#--------------------------------------------------------------
# General
#--------------------------------------------------------------

name                   = "d1c"
environment            = "rc"
application            = "FRDG"
aws_profile            = "default"
region                 = "us-west-2"
role_arn               = "arn:aws:iam::936562317728:role/CrossAccountAdmin"


#--------------------------------------------------------------
# General
#--------------------------------------------------------------
# s3://itxcdn/_private/bootstraps/sgw-edge.sh

# chmod +x bootstrap-sgw-edge.sh

#  REGION=`curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep <http://169.254.169.254/latest/dynamic/instance-identity/document%7cgrep>  region|awk -F\" '{print $4}'`

# ./bootstrap-sgw-edge.sh -r $REGION