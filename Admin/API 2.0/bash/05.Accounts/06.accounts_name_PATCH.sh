#!/bin/bash

#
# Get the directory of the script
#
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# 
# First we will load the variables into our context.
# Ensure that the path is correct and you have made the necessary changes.
#
printf "Loading variables into our context..."
source "${SCRIPT_DIR}/../set_variables.sh"

# The PATCH Method has 3 types of operations: add, remove, and replace.

# OPERATION = ADD
# The add operation is best suited for arrays. You can use it to add a new element to an empty or non-empty array.

# In our first example, lets add an element to the "addressBookSettings.sources" array.
# The syntax "addressBookSettings.sources" means that there is a first level property named "addressBookSettings"
# and under that object, there is a property named "sources".

ACCOUNT="john"

# The result will be in the following format:
# ...
# "addressBookSettings" : {
#     "policy" : "default",
#     "nonAddressBookCollaborationAllowed" : null,
#     "sources" : [ {
#       "id" : "8a050087950494eb0195049650c60000",
#       "name" : "LDAP",
#       "type" : "LDAP",
#       "parentGroup" : "LDAP",
#       "enabled" : true,
#       "customProperties" : {
#         "MaxPageEntries" : "100",
#         "ldapDomainName" : "Logged In (current user domain)"
#       }
#     }, {
#       "id" : "8a050087950494eb01950496545d0002",
#       "name" : "Local",
#       "type" : "LOCAL",
#       "parentGroup" : "Local",
#       "enabled" : true,
#       "customProperties" : {
#         "buType" : "allBU"
#       }
#     } ],
#     "contacts" : [ ]
#   }
# ...
# We will use the replace operation on policy. 
# From the schema we can see that the policy can be "default", "custom" or "disabled".
# We will change the policy to "custom". 
# ...


printf "Getting the account %s and filtering only the addressBookSettings...\n" "${ACCOUNT}"
curl -k -u ${USER}:${PWD}  -X GET "https://${SERVER}:${PORT}/api/v2.0/accounts/${ACCOUNT}?type=user&fields=addressBookSettings.policy,addressBookSettings.nonAddressBookCollaborationAllowed" -H "accept: */*"

printf "Changing the policy to custom...\n"
curl -k -u ${USER}:${PWD}  -X PATCH "https://${SERVER}:${PORT}/api/v2.0/accounts/${ACCOUNT}" -H "accept: */*" -H 'Content-Type: application/json' -d '[
  {
    "op": "replace",
    "path": "/addressBookSettings/policy",
    "value": "custom"
  }
  ]'

# Now let's repeat the querry, but this time try to modify two parameters at once.
printf "Changing two fields at the same time...\n"
curl -k -u ${USER}:${PWD}  -X PATCH "https://${SERVER}:${PORT}/api/v2.0/accounts/${ACCOUNT}" -H "accept: */*" -H 'Content-Type: application/json' -d '[
  {
    "op": "replace",
    "path": "/addressBookSettings/policy",
    "value": "default"
  },
  {
    "op": "replace",
    "path": "/addressBookSettings/nonAddressBookCollaborationAllowed",
    "value": "true"
  }
  ]'

printf "Removing the addressBookSettings.nonAddressBookCollaborationAllowed...\n"
curl -k -u ${USER}:${PWD}  -X PATCH "https://${SERVER}:${PORT}/api/v2.0/accounts/${ACCOUNT}" -H "accept: */*" -H 'Content-Type: application/json' -d '[
  {
    "op": "remove",
    "path": "/addressBookSettings/nonAddressBookCollaborationAllowed"
  }
  ]'

printf "Checking the result...\n"
curl -k -u ${USER}:${PWD}  -X GET "https://${SERVER}:${PORT}/api/v2.0/accounts/${ACCOUNT}?type=user&fields=addressBookSettings.nonAddressBookCollaborationAllowed" -H "accept: */*"

printf "Adding a new contact...\n"
curl -k -u "${USER}:${PWD}"  -X PATCH "https://${SERVER}:${PORT}/api/v2.0/accounts/${ACCOUNT}" -H "accept: */*" -H 'Content-Type: application/json' -d '[
  {
    "op": "add",
    "path": "/addressBookSettings/contacts/1",
    "value": {
      "fullName": "Jane Doe",
      "primaryEmail": "jane.doe@abc.com"
    }
}]'