require "../spec_helper"
require "colorize"
require "../../src/tasks/utils/utils.cr"
require "../../src/tasks/kind_setup.cr"
require "file_utils"
require "sam"

describe "5g" do

  before_all do
    `./cnf-testsuite setup`
    $?.success?.should be_true
  end

  it "'5g_suci_enabled' should pass if the 5G core has suci enabled", tags: ["5g"]  do
    begin
      `/bin/bash -c "#{Dir.current}/spec/5g/key-setup.sh"`
      KubectlClient::Create.command("-f ./configmap.yml")
      Helm.fetch("openverso/open5gs --version 2.0.11 --untar")
      File.copy("#{Dir.current}/spec/fixtures/udm-config-open5gs.yml", "#{Dir.current}/open5gs/charts/open5gs-udm/resources/config/udm.yaml")
      Helm.install("open5gs #{Dir.current}/open5gs --values #{Dir.current}/spec/fixtures/5g-core-config.yml")
      KubectlClient::Get.wait_for_install("open5gs-pcf")
      $?.success?.should be_true
#      (/PASSED: CNF compatible with both Calico and Cilium/ =~ response_s).should_not be_nil
    end
  end

  #TODO exec tshark command: tshark -ni any -Y nas_5gs.mm.type_id  -T json
  #TODO parse tshark command
  #TODO look for authentication text
  # extra
  #TODO look for connection text (sanity check)
  #TODO tshark library
  #TODO 5g tools library
  #TODO 5g RAN and Core mobile traffic check (connection check)
  #TODO 5g RAN (only) mobile traffic check ????
  #TODO ueransim library (w/setup command)
  #TODO Open5gs libary (w/setup command)


end
