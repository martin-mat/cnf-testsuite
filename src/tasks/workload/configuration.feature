Feature: CNF configuration

  @cert
  Scenario: Require labels
    # Reasoning: Defining and using labels help identify semantic attributes of an application or Deployment. A common set of labels allows tools to work collaboratively, while describing objects in a common manner that all tools can understand. Recommended labels should be used to describe applications in a way that can be queried.
    # Remediation: Make sure to define app.kubernetes.io/name label under metadata for your CNF.
    Given CNF is deployed
    When Kyverno is installed
    And Labels of all PODs of CNF are read using Kyverno
    Then All PODs have app.kubernetes.io/name label

  Scenario: Versioned tag
    # Reasoning: "latest" tag should be avoided when deploying containers in production as it is harder to track which version of the image is running and more difficult to roll back properly.
    # Remediation: When specifying container images, always specify a tag and ensure to use an immutable tag that maps to a specific version of an application Pod. Remove any usage of the latest tag, as it is not guaranteed to be always point to the same version of the image.
    Given CNF is deployed
    When OPA is installed
    And Tags of all CNF resources are read using OPA
    Then Following resources contains versioned tags
      | resource_type |
      | deployment |
      | statefulset |
      | pod |
      | replicaset |
      | daemonset |

  @cert @essential
  @pass(100)
  Scenario: Avoid hardcoded IP address in K8s configuration
    # Reasoning: Using a hard coded IP in a CNF's configuration designates how (imperative) a CNF should achieve a goal, not what (declarative) goal the CNF should achieve
    # Remediation: Review all Helm Charts & Kubernetes Manifest files of the CNF and look for any hardcoded usage of ip addresses. If any are found, you will need to use an operator or some other method to abstract the IP management out of your configuration in order to pass this test.
    Given CNF is deployed
    When CNF Helm chart is deployed in dry mode
    And Helm chart is searched for a hardcoded IP address
    Then No hardcoded IP address is found in helm chart
