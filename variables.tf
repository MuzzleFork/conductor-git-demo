"variable" = {
  "awsprops" = {
    "default" = {
      "ami" = "ami-0c1bea58988a989155"

      "itype" = "01GSPPQ94VS1QCSD27HCKNM9V6"

      "keyname" = "myseckey"

      "publicip" = true

      "region" = "us-east-1"

      "secgroupname" = "IAC-Sec-Group"

      "subnet" = "subnet-81896c8e"

      "vpc" = "vpc-5234832d"
    }

    "type" = "map"
  }
}

"variable" = {
  "lucas" = {
    "default" = "${var.awsprops.vpc}"

    "type" = "string"
  }
}