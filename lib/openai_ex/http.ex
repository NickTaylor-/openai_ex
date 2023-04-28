defmodule OpenaiEx.Http do
  @moduledoc false

  @base_url "https://api.openai.com/v1"

  @doc false
  def headers(openai = %OpenaiEx{}) do
    headers = [{"Authorization", "Bearer #{openai.token}"}]

    if is_nil(openai.organization) do
      headers
    else
      headers ++ [{"OpenAI-Organization", openai.organization}]
    end
  end

  @doc false
  def post(openai = %OpenaiEx{}, url, multipart: multipart) do
    body_stream = Multipart.body_stream(multipart)
    content_length = Multipart.content_length(multipart)
    content_type = Multipart.content_type(multipart, "multipart/form-data")

    :post
    |> Finch.build(
      @base_url <> url,
      headers(openai) ++
        [{"Content-Type", content_type}, {"Content-Length", to_string(content_length)}],
      {:stream, body_stream}
    )
    |> finch_run()
  end

  @doc false
  def post(openai = %OpenaiEx{}, url, json: json) do
    :post
    |> Finch.build(
      @base_url <> url,
      headers(openai) ++ [{"Content-Type", "application/json"}],
      Jason.encode_to_iodata!(json)
    )
    |> finch_run()
  end

  @doc false
  def get(openai = %OpenaiEx{}, url) do
    :get
    |> Finch.build(@base_url <> url, headers(openai))
    |> finch_run()
  end

  @doc false
  def delete(openai = %OpenaiEx{}, url) do
    :delete
    |> Finch.build(@base_url <> url, headers(openai))
    |> finch_run()
  end

  @doc false
  def finch_run(finch_request) do
    finch_request
    |> Finch.request!(OpenaiEx.Finch)
    |> Map.get(:body)
    |> Jason.decode!()
  end

  @doc false
  def to_multi_part_form_data(req, file_fields) do
    mp =
      req
      |> Map.drop(file_fields)
      |> Enum.reduce(Multipart.new(), fn {k, v}, acc ->
        acc |> Multipart.add_part(Multipart.Part.text_field(v, k))
      end)

    req
    |> Map.take(file_fields)
    |> Enum.reduce(mp, fn {k, v}, acc ->
      acc |> Multipart.add_part(to_file_field_part(k, v))
    end)
  end

  @doc false
  defp to_file_field_part(k, v) do
    case v do
      {path} ->
        Multipart.Part.file_field(path, k)

      {filename, content} ->
        Multipart.Part.file_content_field(filename, content, k, filename: filename)

      content ->
        Multipart.Part.file_content_field("", content, k, filename: "")
    end
  end
end
