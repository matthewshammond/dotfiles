previousDigits = ['-', '-', '-', '-']

command: "date '+%H:%M'"
refreshFrequency: 1000

render: -> """
  <div class="clock">
    <div class="digits">
      <div class="group">
        <div class="digit" id="h1">
          <div class="top"><div class="content"><span></span></div></div>
          <div class="bottom"><div class="content"><span></span></div></div>
        </div>
        <div class="digit" id="h2">
          <div class="top"><div class="content"><span></span></div></div>
          <div class="bottom"><div class="content"><span></span></div></div>
        </div>
      </div>
      <div class="separator">:</div>
      <div class="group">
        <div class="digit" id="m1">
          <div class="top"><div class="content"><span></span></div></div>
          <div class="bottom"><div class="content"><span></span></div></div>
        </div>
        <div class="digit" id="m2">
          <div class="top"><div class="content"><span></span></div></div>
          <div class="bottom"><div class="content"><span></span></div></div>
        </div>
      </div>
    </div>
  </div>
"""

update: (output) ->
  [h, m] = output.trim().split(":")
  digits = [h[0], h[1], m[0], m[1]]
  ids = ['h1', 'h2', 'm1', 'm2']

  for digit, i in digits
    if digit != previousDigits[i]
      previousDigits[i] = digit

      topSpan = document.querySelector("#" + ids[i] + " .top .content span")
      bottomSpan = document.querySelector("#" + ids[i] + " .bottom .content span")

      topSpan.classList.remove("flip")
      _ = topSpan.offsetWidth  # force reflow
      topSpan.classList.add("flip")

      topSpan.innerText = digit
      bottomSpan.innerText = digit

style: """
  .clock {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
  }

  .digits {
    display: flex;
    align-items: center;
    gap: 0px; /* No gap between the groups */
    /*background: rgba(0, 0, 0, 0.3);*/
    /*padding: 20px 30px;*/
    /*border-radius: 20px;*/
  }


  .group {
    display: flex;
    gap: 20px; /* Keep spacing between digits in each half */
  }

  .digit {
    width: 120px;
    height: 160px;
    display: flex;
    flex-direction: column;
  }

  .top, .bottom {
    height: 50%;
    width: 100%;
    overflow: hidden;
    background: #0c2a28;
    position: relative;
    perspective: 600px;
  }

  .top {
    border-top-left-radius: 12px;
    border-top-right-radius: 12px;
    border-bottom: 1px solid #333;
  }

  .bottom {
    border-bottom-left-radius: 12px;
    border-bottom-right-radius: 12px;
    border-top: 1px solid #111;
  }

  .content {
    height: 320px;
    display: flex;
    justify-content: center;
    align-items: center;
  }

  .top .content {
    transform: translateY(-80px);
  }

  .bottom .content {
    transform: translateY(-160px);
  }

  .content span {
    font-family: 'Menlo', monospace;
    font-size: 160px;
    line-height: 160px;
    color: #fdf6e3;
    display: block;
    backface-visibility: hidden;
    transform-origin: bottom;
  }

  .flip {
    animation: flipDown 0.4s ease-in-out;
  }

  @keyframes flipDown {
    0% {
      transform: rotateX(0deg);
      opacity: 1;
    }
    100% {
      transform: rotateX(90deg);
      opacity: 0;
    }
  }

  .separator {
    font-size: 100px;
    font-family: 'Menlo', monospace;
    color: #fdf6e3;
    line-height: 160px;
    margin: 0 2px; /* Fine-tune this for precise spacing */
    padding: 0;
  }
"""
