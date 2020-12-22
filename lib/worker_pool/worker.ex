defmodule WorkerPool.Worker do
  @moduledoc """
  A worker module for `WorkerPool`.

  You can use it and customize `work`.
  """

  @doc """
  Invoked to perform user-defined processing. 
  """
  @callback work(arg :: term) ::
              {:ok, result :: term}
              | {:error, reason :: String.t()}

  @doc false
  @spec worker(module, non_neg_integer) ::
          {:ok, any}
          | {:error, any}
  def worker(worker_module, wid) do
    receive do
      {:work, arg} ->
        r = worker_module.work(arg)
        create(worker_module, wid) |> WorkerPool.alive(worker_module)
        r
    end
  end

  @doc false
  @spec create(module, non_neg_integer) :: pid
  def create(worker_module, wid) do
    spawn(__MODULE__, :worker, [worker_module, wid])
  end

  defmacro __using__(_opts) do
  end
end
