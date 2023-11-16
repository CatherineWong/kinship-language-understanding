/**
 * kinship-world-models.js
 * WebPPL re-implementation of the base model from https://github.com/gabegrand/world-models/blob/main/domains/d2-relational-reasoning/world-model.scm.
 */

/*** General utility functions. **/
var is_member = function (a, b) {
    return a.includes(b);
}

// Randomly shuffle a list of unique elements. From: http://www.hakank.org/webppl/node_modules/hakank_utils/hakank_utils.wppl 
var shuffle2 = function (a) {
    return draw_without_replacement2(a.length, a, [])
}
var draw_without_replacement2 = function (n, a, res) {
    if (arguments.length == 2) {
        // Fix since I tend to forget the last []
        return draw_without_replacement2(n, a, [])
    }
    var len = a.length
    if (n == 0 || len == 0) {
        return res
    } else {
        var len = a.length
        // Create a temporary array with values 0..len-1
        // and pick one of these values.
        var t = _.range(len)
        var pick = randomInteger(len)
        var selected = t[pick]
        // Removed the picked value
        var new_t = _.without(t, t[pick])
        // Remove the value in a of the pick'th index
        var new_a = map(function (i) { return a[i] }, new_t)
        return draw_without_replacement2(n - 1, new_a, res.concat(a[selected]))
    }
}
// Bounded geometric distribution.
var bounded_geometric = function (p, n, max_n) {
    if (n >= max_n) {
        return max_n
    }
    return flip(p) ? n : bounded_geometric(p, n + 1, max_n)
}
// Shallow flatten. TBD: zyzzyva - check this.
var shallow_flatten = function (x) {
    if (x.length == 0) { return x }
    else if (x.length == 2) {
        return shallow_flatten(x[1]).concat(x[0])
    }
    else {
        return [x]
    }
}

/** NAMING */
// All the names that can be used in the conversational context.
var ALL_NAMES = ['avery', 'blake', 'charlie', 'dana'];

//  Replace unknown names with "other" (for histograms)
var mask_other = function (names) {
    return map(
        function (name) {
            return is_member(ALL_NAMES, name) ? name : 'other';
        }, names)
}

/** WORLD MODEL */
// Generates unique person ids of the format 'person-0', 'person-1'.
var PERSON_PREFIX = "person-"
console.log(PERSON_PREFIX)
gensym