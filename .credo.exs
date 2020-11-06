%{
  configs: [
    %{
      name: "default",
      checks: [
        {Credo.Check.Readability.Specs, []}
      ]
    }
  ]
}