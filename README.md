# Cep-Finder
Cep-Finder is a simple application with just one page that returns address information given a brazilian CEP(Código de Endereçamento Postal).

## Technical Informations
This application makes external http requests to get address information using the AwesomeApi(https://docs.awesomeapi.com.br/api-cep).

CEPs addresses information are immutable. To avoid executing multiple exernal requests searching for the same CEP, when provided a unsearched CEP it will fetch information from the external api and register on database(`cep_searches` table), so everytime it receives the same CEP again it wont make the external request, instead it will return stored information.
### Stack Used
- RubyOnRails
- TailwindCSS with DaisyUI for styling
- Rspec, Capybara, Webmock and FactoryBot for tests
- Rubocop for linter
- Faraday for external http connections
- Brakeman to check dependency security

### Dependencies
- ruby 3.2.3
- rails 8.0.1
- postgres 17.2


## How to configure and execute the application using docker and docker-compose

Build all necessary docker images:
```bash
docker-compose build
```

Execute all containers from application:
```bash
docker-compose up
```

Executing tests(specific tests container):
```bash
docker-compose run --rm tests
```

## How to use the application
After the steps before(Execute all containers from application) you should be able to access the application through `http://localhost:3001/`.

This application has only one page, and it does have the title, a text input, a button and two empty cards. You can fill the text input with some valid brazilian CEP and click in the "Buscar" button, so a new card will appear bellow containing the searched CEP address information. The other two cards below contains the registered information from searched CEPs, the left one has the first five most searched CEPs from any state and has a total count of each one, and the right one shows the most searched CEP from each state.
