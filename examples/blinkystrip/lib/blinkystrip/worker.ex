defmodule Blinkystrip.Worker do
  use GenServer
  #require IEx  ##for debugging

  alias Blinkchain.Point

  defmodule State do
    defstruct [:timer, :colors, :counter]
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    # Send ourselves a message to draw each frame every 100 ms,
    # which will end up being approximately 10 fps.
    {:ok, ref} = :timer.send_interval(100, :draw_frame)

    state = %State{
      timer: ref,
      colors: Blinkystrip.colors(),
      counter: 0
    }

    {:ok, state}
  end

  def handle_info(:draw_frame, state) do

    ## some colors
    red =    %Blinkchain.Color{ r: 255, g: 0,   b: 0}
    blue =   %Blinkchain.Color{ r: 0,   g: 0,   b: 255}
    green =  %Blinkchain.Color{ r: 0,   g: 255, b: 0}
    yellow = %Blinkchain.Color{ r: 0,   g: 255, b: 255}
    white =  %Blinkchain.Color{ r: 255, g: 255, b: 255}

    ## some points on canvas
    origin = %Point{x: 0, y: 0}
    plus_one = %Point{x: 1, y: 0}
    blinky_strip_length = 50
    blinky_strip_width = 1

    ## update counter
    counter = state.counter + 1


    ## rotate thru the rainbow colors
    [next_rainbow | tail] = state.colors

    # Shift all pixels to the right
    Blinkchain.copy(origin, plus_one,
                    blinky_strip_length - 1, blinky_strip_width)

    # decide which color scheme depending on timer
    c0 = case counter do
      c when c == 200 ->
        Blinkchain.fill(plus_one,
                        blinky_strip_length - 1,
                        blinky_strip_width,
                        red)
        white
      c when c > 200 ->
        red
      c when c == 100 ->
        Blinkchain.fill(plus_one,
                        blinky_strip_length - 1,
                        blinky_strip_width,
                        blue)
        white
      c when c > 100 ->
        blue
      _ ->
        # rainbow
        next_rainbow
    end

    #IEx.pry # for debugging

    # Populate the leftmost pixels with new color
    Blinkchain.set_pixel(%Point{x: 0, y: 0}, c0)

    Blinkchain.render()
    {:noreply, %State{state | colors: tail ++ [next_rainbow], counter: counter}}
  end
end
