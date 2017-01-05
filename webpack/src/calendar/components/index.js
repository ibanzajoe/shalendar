function snakeToCamel(s){
  return s.replace(/(\-\w)/g, function(m){return m[1].toUpperCase();});
}

function requireAll(requireContext) {
  return requireContext.keys().reduce( (res, file) => {
    let split = file.split('/')

    if (split.length < 3) return res

    let name = snakeToCamel(split[1])
    res[name] = requireContext(file)

    return res
  }, {});
}

// requires and returns all modules that match
module.exports = requireAll(require.context("./", true, /.vue/));
