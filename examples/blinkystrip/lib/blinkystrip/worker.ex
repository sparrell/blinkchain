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
    orange = %Blinkchain.Color{ r: 255, g: 127, b: 0}
    white  = %Blinkchain.Color{ r: 255, g: 255, b: 255}
    purple = %Blinkchain.Color{ r: 130, g: 0,   b: 75}

    ## some points on canvas
    origin = %Point{x: 0, y: 0}
    plus_one = %Point{x: 1, y: 0}
    bstrip_length = 50
    bstrip_width = 1

    ## update counter
    counter = state.counter + 1


    ## rotate thru the rainbow colors
    [next_rainbow | tail] = state.colors

    #IEX.pry # for debugging

    # Shift all pixels to the right
    Blinkchain.copy(origin, plus_one,
                    bstrip_length - 1, bstrip_width)

    # decide which color scheme depending on timer
    c0 = case counter do
      c when c >= 700 -> # Period 8 is Rainbow
        next_rainbow
      c when c == 600 -> # Period 7 is Red
        Blinkchain.fill(plus_one, bstrip_length - 1, bstrip_width, red)
        white
      c when c > 600 ->
        red
      c when c == 500 -> # Period 6 is purple
        Blinkchain.fill(plus_one, bstrip_length - 1, bstrip_width, purple)
        white
      c when c > 500 ->
        purple
      c when c == 400 -> # Period 5 is Yellow
        Blinkchain.fill(plus_one, bstrip_length - 1, bstrip_width, yellow)
        white
      c when c > 400 ->
        yellow
      c when c == 300 -> # Period 4 is Green
        Blinkchain.fill(plus_one, bstrip_length - 1, bstrip_width, green)
        white
      c when c > 300 ->
        green
      c when c == 200 -> # Period 3 is Blue
        Blinkchain.fill(plus_one, bstrip_length - 1, bstrip_width, blue)
        white
      c when c > 200 ->
        blue
      c when c == 100 ->  # Period 2 is Orange
        Blinkchain.fill(plus_one, bstrip_length - 1, bstrip_width, orange)
        white
      c when c > 100 ->
        orange
      _ ->   # Period 1 is rainbow
        # rainbow
        next_rainbow
    end

    # Populate the leftmost pixels with new color
    Blinkchain.set_pixel(origin, c0)

    #IEX.pry # for debugging

    Blinkchain.render()
    #IEX.pry # for debugging

    {:noreply, %State{state | colors: tail ++ [next_rainbow], counter: counter}}
  end
end
