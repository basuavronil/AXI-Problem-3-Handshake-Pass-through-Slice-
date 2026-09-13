# AXI Handshake Register Slices (Forward & Backward)

## 1. What Is It Used For? (The Relay Race Analogy)

Imagine a long relay race where runners pass a baton back and forth:

* **Short Distance:** If two runners stand right next to each other, handing off the baton and shouting *"Ready!"* happens instantly in real time.
* **Long Distance:** If the track is very long, running and communicating across the entire distance in a single step becomes impossible. In a microchip, long wires cause physical signal delays. If a signal takes too long to cross the chip in one clock cycle, the circuit fails timing closure.

**Register Slices** act as intermediate runners along the track. They place flip-flop registers along the data and handshake lines to cut long paths into shorter segments. This allows the chip to run at significantly higher clock frequencies (MHz/GHz) without dropping data.

---

## 2. Architecture Overview

A standard Ready-Valid handshake consists of two signal paths:
* **Forward Path (`s_valid`, `s_data`):** Payload and valid flags moving from Producer to Consumer.
* **Backward Path (`s_ready`):** Backpressure control signal moving from Consumer to Producer.

Depending on where timing bottlenecks occur, we split register slices into two distinct configurations:

1. **Forward Pass-through Slice:** This is simply the standard **AXI Handshake Register** (as designed in Problem 1). It registers `valid` and `data` on the forward path while passing `ready` back combinationally.
2. **Backward Pass-through Slice:** This is a **Skid Buffer** (as designed in Problem 2). It registers the `ready` signal to break the backpressure timing path, using a 1-entry internal storage register to safely catch incoming payload if the downstream consumer stalls unexpectedly.
