#!/usr/bin/env ruby

options = {
  "cholesky_base_correction"=>[1e-12,1e-10],
  "eta3"=>[0.6, 0.7, 0.8, 0.9],
  "phi2"=>[0.25, 0.5, 0.75, 0.9, 0.99],
  "thetaR"=>[0.1, 0.25, 0.5, 0.75, 0.9, 0.99],
  "use_constraint_scaling"=>[0, 1],
  "use_normal_safe_guard"=>[0, 1],
  "use_objective_scaling"=>[0, 1],
  "use_soc"=>[0, 1],
  "use_variable_scaling"=>[0, 1]
}
keys = options.keys

inds = {}
keys.each { |opt|
  inds[opt] = 0
}

best = 0
best_comb = []

while true
  File.open("dcicpp.awk","w") { |f|
    keys.map { |opt|
      f.puts "/#{opt}/ {print \"#{opt} #{options[opt][inds[opt]]}\"; next}"
    }
    f.puts "{print $0}"
  }
  `awk -f dcicpp.awk dcicpp.spc.original > dcicpp.spc`

  value = `./test-cutest.sh test.list | awk '/Convergence/ {print $4}'`.to_f

  if value > best
    best = value
    best_comb = [inds]
    puts "New optimal: #{best}"
    puts "Option: #{inds.values}"
  elsif value == best
    puts "This option does not improve"
    best_comb << inds
  else
    puts "This option is worst"
  end

  row = 0
  while true
    opt = keys[row]
    inds[opt] += 1
    if inds[opt] >= options[opt].length
      inds[opt] = 0
      row += 1
      if row >= keys.length
        break
      end
    else
      break
    end
  end
  if row >= keys.length
    break
  end
end
