using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

const string tenantId = "8a09f2d7-8415-4296-92b2-80bb4666c5fc";
const string clientId = "4f28598f-2dbe-4ce3-aba1-5350cb5ea288";
const string clientSecret = "zRdJO6eu6FWQ0_59.L~QEDNc3E5LZGa.dD";
const string keyVaultName = "aykeyvaultdemo";
const string secretName = "gssecrettest";

ClientSecretCredential credential = new(tenantId, clientId, clientSecret);
SecretClient client = new(new Uri($"https://{keyVaultName}.vault.usgovcloudapi.net/"), credential);
KeyVaultSecret secret = await client.GetSecretAsync(secretName).ConfigureAwait(false);
Console.WriteLine(secret.Value);

Console.ReadLine();

/*
gov tenant key vault
Tenant:
TEST_TEST_McsInternalTrials
8a09f2d7-8415-4296-92b2-80bb4666c5fc
clientid 4f28598f-2dbe-4ce3-aba1-5350cb5ea288
secret zRdJO6eu6FWQ0_59.L~QEDNc3E5LZGa.dD
keyvault aykeyvaultdemo
secret-name gssecrettest
secret-value p@ssw0rd
*/
