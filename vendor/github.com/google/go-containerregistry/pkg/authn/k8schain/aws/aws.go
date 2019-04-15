package aws

import (
	awscredentialprovider "k8s.io/kubernetes/pkg/credentialprovider/aws"
)

func init() {
	for _, region := range wellKnownRegions {
		awscredentialprovider.RegisterCredentialsProvider(region)
	}
}

// wellKnownRegions is the complete list of regions known to the AWS cloudprovider
// and credentialprovider.
var wellKnownRegions = [...]string{
	// from `aws ec2 describe-regions --region us-east-1 --query Regions[].RegionName | sort`
	"ap-northeast-1",
	"ap-northeast-2",
	"ap-northeast-3",
	"ap-south-1",
	"ap-southeast-1",
	"ap-southeast-2",
	"ca-central-1",
	"eu-central-1",
	"eu-west-1",
	"eu-west-2",
	"eu-west-3",
	"sa-east-1",
	"us-east-1",
	"us-east-2",
	"us-west-1",
	"us-west-2",

	// these are not registered in many / most accounts
	"cn-north-1",
	"cn-northwest-1",
	"us-gov-west-1",
}
