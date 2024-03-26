defmodule EthereumJSONRPC.OpNode do
  alias EthereumJSONRPC

  @doc """
  Gets the bitcoin finality value of the given block hash.

  The bitcoin finality data is provided by "op-node" instead of "op-geth",
  therefore the `json_rpc_named_arguments.method_to_url` map shall contain an
  override for the RPC method.
  """
  def get_block_btc_finality(block_hash) do
    # All requests will share the same id: 0. While this is not a problem and
    # every other request seem to follow the same pattern, it would be better to
    # have unique ids
    request = %{id: 0, jsonrpc: "2.0", method: "optimism_btcFinalityByBlockHash", params: [block_hash]}
    json_rpc_named_arguments = Application.get_env(:explorer, :json_rpc_named_arguments)

    case EthereumJSONRPC.json_rpc(request, json_rpc_named_arguments) do
      # Note: The node currently responds with an array containing one object
      # with the finality data but this will be changed soon so only the object
      # is returned in the result. The function must support both cases in the
      # meantime. This next case could be removed once the node is updated.
      {:ok, [result | _]} ->
        result |> Map.get("btc_finality")

      {:ok, %{"btc_finality" => btc_finality}} ->
        btc_finality

      # If there is an error with the call or there is no finality is retrieved,
      # so the response does not match the previous cases, just return the worst
      # finality value: -9.
      _ ->
        -9
    end
  end
end
