RSpec.shared_context :oas3_resources do
  let(:basic_oas3_content) do
    <<~YAML
      ---
      openapi: "3.0.0"
      info:
        title: "some title"
        description: "some description"
        version: "1.0.0"
      paths:
        /pet:
          get:
            operationId: "getPet"
            responses:
              405:
                description: "invalid input"
    YAML
  end

  let(:servers_oas3_content) do
    <<~YAML
      ---
      openapi: "3.0.0"
      info:
        title: "some title"
        version: "1.0.0"
      servers:
        - url: https://petstore.swagger.io/v1
        - url: https://petstore2.swagger.io/v2
      paths:
        /pet:
          get:
            operationId: "getPet"
            responses:
              405:
                description: "invalid input"
    YAML
  end

  let(:servers_port_oas3_content) do
    <<~YAML
      ---
      openapi: "3.0.0"
      info:
        title: "some title"
        version: "1.0.0"
      servers:
        - url: https://petstore.swagger.io:8080/v1
      paths:
        /pet:
          get:
            operationId: "getPet"
            responses:
              405:
                description: "invalid input"
    YAML
  end

  let(:server_templates_oas3_content) do
    <<~YAML
      ---
      openapi: "3.0.0"
      info:
        title: "some title"
        version: "1.0.0"
      servers:
        - url: https://petstore{version}.swagger.io/v1/{basev1}
          variables:
            basev1:
              default: petstorev1
            unusedvar:
              default: unused
            version:
              default: v1
        - url: https://staging.petstore{version}.swagger.io/v0/{basev1}
          variables:
            basev1:
              default: petstorev0
            unusedvar:
              default: unused
            version:
              default: v0
      paths:
        /pet:
          get:
            operationId: "getPet"
            responses:
              405:
                description: "invalid input"
    YAML
  end


  let(:path_extensions_oas3_content) do
    <<~YAML
      ---
      openapi: "3.0.0"
      info:
        title: "some title"
        version: "1.0.0"
      paths:
        /pet:
          get:
            operationId: "getPet"
            responses:
              200:
                description: "successful operation"
          x-internal-id: 383883
    YAML
  end

  let(:parameters_path_oas3_content) do
    <<~YAML
      ---
      openapi: "3.0.0"
      info:
        title: "some title"
        version: "1.0.0"
      paths:
        /pet/{name}:
          get:
            operationId: "getPet"
            responses:
              200:
                description: "successful operation"
          parameters:
            - name: name
              in: path
              required: true
              schema:
                type: string
    YAML
  end

  let(:multiple_sec_schemas_oas3_content) do
    <<~YAML
      ---
      openapi: "3.0.0"
      info:
        title: "some title"
        version: "1.0.0"
      paths:
        /pet:
          post:
            operationId: "addPet"
            responses:
              405:
                description: "invalid input"
      security:
        - petstore_oauth:
          - write:pets
          - read:pets
        - petstore_api_key: []
        - petstore_basic: []
      components:
        securitySchemes:
          petstore_basic:
            type: http
            scheme: basic
          petstore_api_key:
            type: apiKey
            name: api_key
            in: header
          petstore_oauth:
            type: oauth2
            flows:
              implicit:
                authorizationUrl: http://example.org/api/oauth/dialog
                scopes:
                  write:pets: modify pets in your account
                  read:pets: read your pets
    YAML
  end

  let(:api_key_sec_oas3_content) do
    <<~YAML
      ---
      openapi: "3.0.0"
      info:
        title: "some title"
        version: "1.0.0"
      paths:
        /pet:
          post:
            operationId: "addPet"
            responses:
              405:
                description: "invalid input"
      security:
        - petstore_api_key: []
      components:
        securitySchemes:
          petstore_api_key:
            type: apiKey
            name: api_key
            in: header
    YAML
  end

  let(:oauth2_implicit_oas3_content) do
    <<~YAML
      ---
      openapi: "3.0.0"
      info:
        title: "some title"
        version: "1.0.0"
      paths:
        /pet:
          post:
            operationId: "addPet"
            responses:
              405:
                description: "invalid input"
      security:
        - petstore_oauth:
          - write:pets
          - read:pets
      components:
        securitySchemes:
          petstore_oauth:
            type: oauth2
            flows:
              implicit:
                authorizationUrl: http://example.org/api/oauth/dialog
                scopes:
                  write:pets: modify pets in your account
                  read:pets: read your pets
    YAML
  end

  let(:oauth2_password_oas3_content) do
    <<~YAML
      ---
      openapi: "3.0.0"
      info:
        title: "some title"
        version: "1.0.0"
      paths:
        /pet:
          post:
            operationId: "addPet"
            responses:
              405:
                description: "invalid input"
      security:
        - petstore_oauth:
          - write:pets
          - read:pets
      components:
        securitySchemes:
          petstore_oauth:
            type: oauth2
            flows:
              password:
                tokenUrl: http://example.org/api/oauth/dialog
                scopes:
                  write:pets: modify pets in your account
                  read:pets: read your pets
    YAML
  end

  let(:oauth2_clientCredentials_oas3_content) do
    <<~YAML
      ---
      openapi: "3.0.0"
      info:
        title: "some title"
        version: "1.0.0"
      paths:
        /pet:
          post:
            operationId: "addPet"
            responses:
              405:
                description: "invalid input"
      security:
        - petstore_oauth:
          - write:pets
          - read:pets
      components:
        securitySchemes:
          petstore_oauth:
            type: oauth2
            flows:
              clientCredentials:
                tokenUrl: http://example.org/api/oauth/dialog
                scopes:
                  write:pets: modify pets in your account
                  read:pets: read your pets
    YAML
  end

  let(:oauth2_authorizationCode_oas3_content) do
    <<~YAML
      ---
      openapi: "3.0.0"
      info:
        title: "some title"
        version: "1.0.0"
      paths:
        /pet:
          post:
            operationId: "addPet"
            responses:
              405:
                description: "invalid input"
      security:
        - petstore_oauth:
          - write:pets
          - read:pets
      components:
        securitySchemes:
          petstore_oauth:
            type: oauth2
            flows:
              authorizationCode:
                tokenUrl: http://example.org/api/oauth/dialog
                authorizationUrl: http://example.org/api/oauth/dialog
                scopes:
                  write:pets: modify pets in your account
                  read:pets: read your pets
    YAML
  end

  let(:oauth2_multiple_flow_oas3_content) do
    <<~YAML
      ---
      openapi: "3.0.0"
      info:
        title: "some title"
        version: "1.0.0"
      paths:
        /pet:
          get:
            operationId: "getPet"
            responses:
              200:
                description: "successful operation"
      security:
        - petstore_oauth:
          - write:pets
          - read:pets
      components:
        securitySchemes:
          petstore_oauth:
            type: oauth2
            flows:
              clientCredentials:
                tokenUrl: http://example.org/api/oauth/dialog
                scopes:
                  write:pets: modify pets in your account
                  read:pets: read your pets
              authorizationCode:
                authorizationUrl: https://example.com/api/oauth/dialog
                tokenUrl: http://example.org/api/oauth/token
                scopes:
                  write:pets: modify pets in your account
              implicit:
                authorizationUrl: http://example.org/api/oauth/dialog
                scopes:
                  write:pets: modify pets in your account
              password:
                tokenUrl: http://example.org/api/oauth/dialog
                scopes:
                  write:pets: modify pets in your account
                  read:pets: read your pets
                  read:pets: read your pets
    YAML
  end

  let(:basic_sec_oas3_content) do
    <<~YAML
      ---
      openapi: "3.0.0"
      info:
        title: "some title"
        version: "1.0.0"
      paths:
        /pet:
          post:
            operationId: "addPet"
            responses:
              405:
                description: "invalid input"
      security:
        - petstore_basic: []
      components:
        securitySchemes:
          petstore_basic:
            type: http
            scheme: basic
    YAML
  end
end
