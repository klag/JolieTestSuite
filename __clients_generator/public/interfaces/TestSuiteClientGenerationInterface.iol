type GenerateRequest: void {
      .main_file: string
      .target_folder: string
      .generate_data: bool
      .http_test_suite_location: string
}

type GenerateResponse: void 


interface TestSuiteClientGenerationInterface {
RequestResponse:
    generate( GenerateRequest )( GenerateResponse )
}