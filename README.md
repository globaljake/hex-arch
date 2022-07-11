# hex-arch

Loosely coupled statically typed front end at scale based on Moore Machines for state management and Hexagonal Architecture as inter-model communication

- The Elm Architecture directly correlates with a Moore Machine
  Elm (Model, init, Msg, Html Msg, update, view) -> Moore Machine (State, Initial State, Input Library, Output Library, Transition Function, Output Function)

- Treat every elm triple (Model, init, Msg, Html Msg, update, view) as a seperate Moore Machine and solve communication between Moore Machines with Hexagonal Architecture to more loosely couple and best scale front end applications
