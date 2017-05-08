defmodule PageControllerSpec do
  use ESpec
  it do: expect true |> to(be_true())
  it do: expect(1 + 1).to eq(2)
  it do: (1..3) |> should(have 2)
end
