defmodule OpenaiEx.ChatCompletion do
  @moduledoc """
  This module provides an implementation of the OpenAI chat completions API. The API reference can be found at https://platform.openai.com/docs/api-reference/chat/completions.

  ## API Fields

  The following fields can be used as parameters when creating a new chat completion:

  - `:model`
  - `:messages`
  - `:temperature`
  - `:top_p`
  - `:n`
  - `:stream`
  - `:stop`
  - `:max_tokens`
  - `:presence_penalty`
  - `:frequency_penalty`
  - `:logit_bias`
  - `:user`
  """
  @api_fields [
    :model,
    :messages,
    :temperature,
    :top_p,
    :n,
    :stream,
    :stop,
    :max_tokens,
    :presence_penalty,
    :frequency_penalty,
    :logit_bias,
    :user
  ]

  @doc """
  Creates a new chat completion request with the given arguments.

  ## Arguments

  - `args`: A list of key-value pairs, or a map, representing the fields of the chat completion request.

  ## Returns

  A map containing the fields of the chat completion request.

  The `:model` and `:messages` fields are required. The `:messages` field should be a list of maps with the `OpenaiEx.ChatMessage` structure.

  Example usage:

      iex> _request = OpenaiEx.ChatCompletion.new([model: "davinci", messages: [OpenaiEx.ChatMessage.user("Hello, world!")]])
      %{messages: [%{content: "Hello, world!", role: "user"}], model: "davinci"}

      iex> _request = OpenaiEx.ChatCompletion.new(%{model: "davinci", messages: [OpenaiEx.ChatMessage.user("Hello, world!")]})
      %{messages: [%{content: "Hello, world!", role: "user"}], model: "davinci"}
  """

  def new(args = [_ | _]) do
    args |> Enum.into(%{}) |> new()
  end

  def new(args = %{model: model, messages: messages}) do
    %{
      model: model,
      messages: messages
    }
    |> Map.merge(args)
    |> Map.take(@api_fields)
  end

  @doc """
  Calls the chat completion 'create' endpoint.

  ## Arguments

  - `openai`: The OpenAI configuration.
  - `chat_completion`: The chat completion request, as a map with keys corresponding to the API fields.

  ## Returns

  A map containing the API response.

  See https://platform.openai.com/docs/api-reference/chat/completions/create for more information.
  """
  def create(openai = %OpenaiEx{}, chat_completion = %{}) do
    openai |> OpenaiEx.post("/chat/completions", json: chat_completion |> Map.take(@api_fields))
  end
end
