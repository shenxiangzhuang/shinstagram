defmodule Shinstagram.AI do
  import Qwen.Sigils


  def save_cos(image_url, image_name) do
    image_binary = Req.get!(image_url).body

    # bucket = System.get_env("BUCKET_NAME")


    {:ok, resp} = COS.Object.put(
      "https://llm-1252464519.cos.ap-beijing.myqcloud.com",
      "qwen/#{image_name}",
      image_binary,
      headers: [{"content-type", "image/png"}]
      )


    # {:ok, "#{System.get_env("CLOUDFLARE_PUBLIC_URL")}/#{file_name}"}
    image_name_encode = URI.encode_www_form(image_name)
    IO.puts("https://llm-1252464519.cos.ap-beijing.myqcloud.com/qwen/#{image_name_encode}")
    {:ok, "https://llm-1252464519.cos.ap-beijing.myqcloud.com/qwen/#{image_name_encode}"}
  end

  def gen_image({:ok, image_prompt}), do: gen_image(image_prompt)

  @doc """
  Generates an image given a prompt. Returns {:ok, url} or {:error, error}.
  """
  def gen_image(image_prompt) when is_binary(image_prompt) do
    image_prompt = ~p"model: wanx-v1
                      prompt: #{image_prompt}
                      parameters.style: <chinese painting>
                      parameters.size: 1024*1024
                      parameters.n: 1
                      parameters.seed: 42"

    {:ok, image_url} = image_prompt |> Qwen.text_to_image
    # image_url = "https://dashscope-result-sh.oss-cn-shanghai.aliyuncs.com/1d/aa/20240312/3ab595ad/9dc0eec6-a0e9-4a16-b2fd-c01ea1f2f423-1.png?Expires=1710337020&OSSAccessKeyId=LTAI5tQZd8AEcZX6KZV4G8qL&Signature=jN84pIz46ScJeFAkj%2B087KjG0%2Bc%3D"

    # TODO: better image_name logic
    image_id = Regex.run(~r/.*\/(.*?\.png).*?/, image_url) |> List.last
    # String.replace(" ", "_"): URI.encode_www_form will encode space to "+" rather than %2B
    datetime = DateTime.utc_now() |> DateTime.to_string |> String.replace(" ", "_")
    save_cos(image_url, "[#{datetime}]#{image_id}")
  end

  def chat_completion(text) do
    text
    |> Qwen.chat
  end
end
