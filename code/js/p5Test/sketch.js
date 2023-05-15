

import Alglib from 'https://cdn.jsdelivr.net/gh/Pterodactylus/Alglib.js@master/Alglib-v1.1.0.js'

var fun = function(x) {
    return Math.sin(x) + Math.cos(x);
}

let solver = new Alglib()
solver.add_function(fun)

solver.promise.then(function(result){
    var x_guess = 0.5
    var s = solver.solve("min", x_guess)
    console.log(solver.get_results())
})

