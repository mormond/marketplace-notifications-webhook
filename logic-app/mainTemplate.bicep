param location string = resourceGroup().location

var workflowName = 'managed-app-webhook-1'

resource workflow_resource 'Microsoft.Logic/workflows@2017-07-01' = {
  name: workflowName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            schema: {
              properties: {
                appName: {
                  type: 'string'
                }
                applicationId: {
                  type: 'string'
                }
                eventTime: {
                  type: 'string'
                }
                eventType: {
                  type: 'string'
                }
                githubWorkflowDispatchUri: {
                  type: 'string'
                }
                plan: {
                  properties: {
                    name: {
                      type: 'string'
                    }
                    product: {
                      type: 'string'
                    }
                    publisher: {
                      type: 'string'
                    }
                    version: {
                      type: 'string'
                    }
                  }
                  type: 'object'
                }
                provisioningState: {
                  type: 'string'
                }
                rgName: {
                  type: 'string'
                }
                subscriptionId: {
                  type: 'string'
                }
              }
              type: 'object'
            }
          }
        }
      }
      actions: {
        Get_secret: {
          runAfter: {
            Parse_outputs: [
              'Succeeded'
            ]
          }
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'keyvault\'][\'connectionId\']'
              }
            }
            method: 'get'
            path: '/secrets/@{encodeURIComponent(\'GH-SECRET\')}/value'
          }
        }
        HTTP: {
          runAfter: {
            Get_secret: [
              'Succeeded'
            ]
          }
          type: 'Http'
          inputs: {
            body: {
              inputs: {
                clusterName: '@string(body(\'Parse_properties\')?[\'parameters\']?[\'aksClusterName\'].value)'
                kvName: '@body(\'Parse_outputs\')?[\'keyVaultName\'].value'
                kvSecretProviderIdentity: '@{body(\'Parse_outputs\')?[\'keyVaultSecretProviderManagedIdentity\'].value}'
                resourceGroup: '@{body(\'Parse_outputs\')?[\'customerManagedResourceGroupName\'].value}'
                subscriptionId: '@{body(\'Parse_outputs\')?[\'customerSubscriptionId\'].value}'
                tenantId: '@{body(\'Parse_outputs\')?[\'customerTenantId\'].value}'
              }
              ref: 'main'
            }
            headers: {
              Accept: 'application/vnd.github.v3+json'
              Authorization: 'token @{body(\'Get_secret\')?[\'value\']}'
            }
            method: 'POST'
            uri: '@triggerBody()?[\'githubWorkflowDispatchUri\']'
          }
        }
        List_managed_app_resource: {
          runAfter: {}
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'arm\'][\'connectionId\']'
              }
            }
            method: 'get'
            path: '/subscriptions/@{encodeURIComponent(triggerBody()?[\'subscriptionId\'])}/resourcegroups/@{encodeURIComponent(triggerBody()?[\'rgName\'])}/providers/@{encodeURIComponent(\'Microsoft.Solutions\')}/@{encodeURIComponent(\'applications/\',triggerBody()?[\'appName\'])}'
            queries: {
              'x-ms-api-version': '2021-07-01'
            }
          }
        }
        Parse_outputs: {
          runAfter: {
            Parse_properties: [
              'Succeeded'
            ]
          }
          type: 'ParseJson'
          inputs: {
            content: '@body(\'Parse_properties\')?[\'outputs\']'
            schema: {
              properties: {
                controlPlaneFQDN: {
                  properties: {
                    type: {
                      type: 'string'
                    }
                    value: {
                      type: 'string'
                    }
                  }
                  type: 'object'
                }
                customerManagedResourceGroupName: {
                  properties: {
                    type: {
                      type: 'string'
                    }
                    value: {
                      type: 'string'
                    }
                  }
                  type: 'object'
                }
                customerSubscriptionId: {
                  properties: {
                    type: {
                      type: 'string'
                    }
                    value: {
                      type: 'string'
                    }
                  }
                  type: 'object'
                }
                customerTenantId: {
                  properties: {
                    type: {
                      type: 'string'
                    }
                    value: {
                      type: 'string'
                    }
                  }
                  type: 'object'
                }
                keyVaultName: {
                  properties: {
                    type: {
                      type: 'string'
                    }
                    value: {
                      type: 'string'
                    }
                  }
                  type: 'object'
                }
                keyVaultSecretProviderManagedIdentity: {
                  properties: {
                    type: {
                      type: 'string'
                    }
                    value: {
                      type: 'string'
                    }
                  }
                  type: 'object'
                }
              }
              type: 'object'
            }
          }
        }
        Parse_properties: {
          runAfter: {
            List_managed_app_resource: [
              'Succeeded'
            ]
          }
          type: 'ParseJson'
          inputs: {
            content: '@body(\'List_managed_app_resource\')?[\'properties\']'
            schema: {
              properties: {
                authorizations: {
                  items: {
                    properties: {
                      principalId: {
                        type: 'string'
                      }
                      roleDefinitionId: {
                        type: 'string'
                      }
                    }
                    required: [
                      'principalId'
                      'roleDefinitionId'
                    ]
                    type: 'object'
                  }
                  type: 'array'
                }
                createdBy: {
                  properties: {
                    applicationId: {
                      type: 'string'
                    }
                    oid: {
                      type: 'string'
                    }
                    puid: {
                      type: 'string'
                    }
                  }
                  type: 'object'
                }
                customerSupport: {
                  properties: {
                    contactName: {
                      type: 'string'
                    }
                    email: {
                      type: 'string'
                    }
                    phone: {
                      type: 'string'
                    }
                  }
                  type: 'object'
                }
                managedResourceGroupId: {
                  type: 'string'
                }
                managementMode: {
                  type: 'string'
                }
                outputs: {
                  properties: {
                    controlPlaneFQDN: {
                      properties: {
                        type: {
                          type: 'string'
                        }
                        value: {
                          type: 'string'
                        }
                      }
                      type: 'object'
                    }
                    customerManagedResourceGroupName: {
                      properties: {
                        type: {
                          type: 'string'
                        }
                        value: {
                          type: 'string'
                        }
                      }
                      type: 'object'
                    }
                    customerSubscriptionId: {
                      properties: {
                        type: {
                          type: 'string'
                        }
                        value: {
                          type: 'string'
                        }
                      }
                      type: 'object'
                    }
                    customerTenantId: {
                      properties: {
                        type: {
                          type: 'string'
                        }
                        value: {
                          type: 'string'
                        }
                      }
                      type: 'object'
                    }
                    keyVaultName: {
                      properties: {
                        type: {
                          type: 'string'
                        }
                        value: {
                          type: 'string'
                        }
                      }
                      type: 'object'
                    }
                    keyVaultSecretProviderManagedIdentity: {
                      properties: {
                        type: {
                          type: 'string'
                        }
                        value: {
                          type: 'string'
                        }
                      }
                      type: 'object'
                    }
                  }
                  type: 'object'
                }
                parameters: {
                  properties: {
                    aksClusterName: {
                      properties: {
                        type: {
                          type: 'string'
                        }
                        value: {
                          type: 'string'
                        }
                      }
                      type: 'object'
                    }
                    dnsPrefix: {
                      properties: {
                        type: {
                          type: 'string'
                        }
                        value: {
                          type: 'string'
                        }
                      }
                      type: 'object'
                    }
                    location: {
                      properties: {
                        type: {
                          type: 'string'
                        }
                        value: {
                          type: 'string'
                        }
                      }
                      type: 'object'
                    }
                    vaultName: {
                      properties: {
                        type: {
                          type: 'string'
                        }
                        value: {
                          type: 'string'
                        }
                      }
                      type: 'object'
                    }
                    vaultResourceGroupName: {
                      properties: {
                        type: {
                          type: 'string'
                        }
                        value: {
                          type: 'string'
                        }
                      }
                      type: 'object'
                    }
                    vaultSubscriptionId: {
                      properties: {
                        type: {
                          type: 'string'
                        }
                        value: {
                          type: 'string'
                        }
                      }
                      type: 'object'
                    }
                  }
                  type: 'object'
                }
                provisioningState: {
                  type: 'string'
                }
                publisherTenantId: {
                  type: 'string'
                }
                supportUrls: {
                  properties: {
                    publicAzure: {
                      type: 'string'
                    }
                  }
                  type: 'object'
                }
                updatedBy: {
                  properties: {
                    applicationId: {
                      type: 'string'
                    }
                    oid: {
                      type: 'string'
                    }
                    puid: {
                      type: 'string'
                    }
                  }
                  type: 'object'
                }
              }
              type: 'object'
            }
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          arm: {
            connectionId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/connections/arm'
            connectionName: 'arm'
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/arm'
          }
          keyvault: {
            connectionId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/connections/keyvault'
            connectionName: 'keyvault'
            connectionProperties: {
              authentication: {
                type: 'ManagedServiceIdentity'
              }
            }
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/keyvault'
          }
        }
      }
    }
  }
}
