log("RectifyProperties called")

state.portCount = getPortCount(resolveModel(props))

props.RebuildGUI = true
return props
