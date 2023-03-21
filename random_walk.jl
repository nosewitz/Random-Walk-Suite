using Plots, Distributions





function randomWalk(steps::Int, n::Int; rate = 1)
      path = zeros(Int, steps, n)
      # Starting direction
      dir = rand(1:n)
      path[1, dir] = rate
      rates = (-rate,rate)
      for i in 2:steps
            dir = rand(1:n)
            path[i, :] .= path[i-1, :]
      	path[i, dir] += rand(rates)
      end
	path
end

function randomWalk(steps::Int, n::Int, dist; rate = 1)
      path = zeros(eltype(dist), steps, n)
      # Starting direction
      dir = rand(1:n)

      path[1, dir] =  rand(dist)*rate

      for i in 2:steps
            dir = rand(1:n)
            path[i, :] .= path[i-1, :]
      	path[i, dir] += rand(dist)*rate
      end
	path
end

# Multiple walkers
randomWalk(steps::Int, n::Int, walkers::Int; rate = 1) =  [ randomWalk(steps, n; rate=rate) for walker in 1:walkers ]
randomWalk(steps::Int, n::Int, walkers::Int, dist) =  [ randomWalk(steps, n, dist) for walker in 1:walkers ]


walk2D(path; walker = 1, color = :blue, alpha = 1., size = (700,700) ) = @views plot(path[:,1], path[:,2], color = color, alpha = alpha, size=size,  label = "Walker $walker", ratio = :equal)
walk2D(plt, path; walker = 1, color = :blue, alpha = 1., size = (700,700)) = @views plot!(path[:,1], path[:,2], color = color, alpha = alpha,  size=size,  label = "Walker $walker", ratio = :equal)


walk3D(path; walker = 1, color=:blue, alpha=1., size = (700,700)) = plot(path[:,1], path[:,2], path[:,3], color = color, alpha=alpha, size=size,  label = "Walker $walker", ratio = :equal)
walk3D(plt, path; walker = 1, color=color, alpha=1., size = (700,700)) = plot!(path[:,1], path[:,2], path[:,3], color = color, alpha=alpha, size=size, label = "Walker $walker", ratio = :equal)


"""Dispatch for a single random walk path"""
randomWalkPlot(path::AbstractMatrix; walker = 1, color = :blue, alpha = 1.) = size(path, 2) == 2 ? walk2D(path; walker = walker, color=color, alpha = alpha) : walk3D(path;  walker = walker, color=color, alpha = alpha)

"""Dispatch for adding walkers onto a plot, plt"""
randomWalkPlot(plt, path::AbstractMatrix; walker = 1, color = :blue, alpha = 1.) = size(path, 2) == 2 ? walk2D(plt, path; walker = walker, color=color, alpha = alpha, ) : walk3D(plt, path;  walker = walker, color=color, alpha = alpha)


function randomWalkPlot(steps::Int, n::Int; color = :blue, alpha = 1., size = (700,700))
      path = randomWalk(steps, n)

	if n == 2
           walk2D(path; color=color, alpha = alpha, )
      else
	
           walk3D(path; color=color, alpha = alpha, )
	end
end

function randomWalkPlot(steps::Int, n::Int, dist::Distribution; color = :blue, alpha = 1., rate = 1, size = (700,700))
      path = randomWalk(steps, n, dist)

	if n == 2
           walk2D(path; color=color, alpha = alpha, )
      else
           walk3D(path; color=color, alpha = alpha, )
	end
end


function randomWalkPlot(steps::Int, n::Int, walkers::Int; alpha=.3)
      paths = randomWalk(steps, n, walkers)
	
      p = plot(title = "Random Walk in $n Dimensions")
	for (i,path) in enumerate(paths)
		randomWalkPlot(p, path; color = rand(1:1000), walker = i, alpha=alpha )
	end
	p
end

function randomWalkPlot(steps, n, walkers, dist; alpha=.3, size = (1000,1000))
      paths = randomWalk(steps, n, walkers, dist)
	
      # Remove parametrization portion of distribution string
      formattedDist = replace(string(dist), r"\{.*?\}" => "")

      p = plot(title = "$formattedDist Distributed Random Walk in $(n)D\n",
               size=size,
               alpha=alpha,
               legend = :outertopleft)
               
	for (i, path) in enumerate(paths)
		randomWalkPlot(p, path; color = rand(1:1000), walker = i  )
	end
	p
end

#### Plots.jl animations

abstract type RandomWalk end

mutable struct RandomWalk2D <: RandomWalk
      x
      y
      const dist
end

mutable struct RandomWalk3D <: RandomWalk
      x
      y
      z
      const dist
end

RandomWalk2D(distribution) = RandomWalk2D(zero(eltype(distribution)),zero(eltype(distribution)), distribution)
RandomWalk3D(distribution) = RandomWalk3D(zero(eltype(distribution)),zero(eltype(distribution)), zero(eltype(distribution)), distribution)

function step!(rw::RandomWalk)
      field = rand( fieldnames( typeof(rw) )[begin:end-1] )
      newval = getfield(rw, field) + rand( rw.dist )
      #@show field, newval
      setfield!(rw, field, newval)
end

gr()
rw = RandomWalk3D(Normal())
plt = plot3d(
    1,
    xlim = (-10, 7),
    ylim = (-10, 7),
    zlim = (-10, 7),
    title = "Random Walk",
    marker = 2,
)

t= @animate for i=1:100
      step!(rw)
      push!(plt, rw.x, rw.y, rw.z)
  end
gif(t, "anim_fps15.gif", fps = 10)
