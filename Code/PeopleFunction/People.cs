using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using Bogus;
using Bogus.DataSets;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Enums;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;
using Newtonsoft.Json;
using Person = PeopleModel.Person;

namespace PeopleFunction
{
    public class People
    {
        private readonly ILogger<People> logger;

        public People(ILogger<People> log)
        {
            logger = log;
        }

        [FunctionName("People")]
        [OpenApiOperation(operationId: "Run", tags: new[] { "name" })]
        [OpenApiSecurity("function_key", SecuritySchemeType.ApiKey, Name = "code", In = OpenApiSecurityLocationType.Query)]
        [OpenApiParameter(name: "howManyPeople", In = ParameterLocation.Query, Required = false, Type = typeof(int), Description = "The number of people you need (default is 5)")]
        [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: "application/json", bodyType: typeof(List<Person>), Description = "OK response")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = null)]
            HttpRequest req)
        {
            logger.LogInformation("C# HTTP trigger function processed a request.");

            string howManyPeople = req.Query["howManyPeople"];
            if (string.IsNullOrEmpty(howManyPeople))
            {
                string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
                dynamic data = JsonConvert.DeserializeObject(requestBody);
                howManyPeople = data?.howManyPeople;
            }

            int peopleToGenerate = !string.IsNullOrEmpty(howManyPeople) && howManyPeople.All(char.IsDigit) ? Convert.ToInt32(howManyPeople) : 5;

            //Set the randomizer seed
            Randomizer.Seed = new Random(8675309);

            int userIds = 0;
            Faker<Person> testUsers = new Faker<Person>()
                .CustomInstantiator(f => new Person(userIds++))
                .RuleFor(u => u.Gender, f => f.PickRandom<PeopleModel.Gender>().ToString())
                .RuleFor(u => u.FirstName, (f, u) => f.Name.FirstName(u.Gender == "Male" ? Name.Gender.Male : Name.Gender.Female))
                .RuleFor(u => u.LastName, (f, u) => f.Name.LastName())
                .RuleFor(u => u.Avatar, f => f.Internet.Avatar())
                .RuleFor(u => u.UserName, (f, u) => f.Internet.UserName(u.FirstName, u.LastName))
                .RuleFor(u => u.Email, (f, u) => f.Internet.Email(u.FirstName, u.LastName))
                .RuleFor(p => p.StreetAddress, f => f.Address.StreetAddress())
                .RuleFor(p => p.City, f => f.Address.City())
                .RuleFor(p => p.State, f => f.Address.StateAbbr())
                .RuleFor(p => p.ZipCode, f => f.Address.ZipCode())
                .RuleFor(p => p.Phone, f => f.Phone.PhoneNumber("(###)-###-####"))
                .FinishWith((f, u) => { logger.LogInformation("User Created! Id={0}", u.Id); });

            List<Person> people = testUsers.Generate(peopleToGenerate);

            return new OkObjectResult(people);
        }
    }
}
