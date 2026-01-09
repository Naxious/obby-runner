export type Projectile = {
	id: string, -- string representng KeyValue for the ProjectileData table

	gravityScale: number, -- gravity scale for the projectile
	radius: number, -- radius for the projectile
	totalTime: number, -- total time in seconds before projectile auto ends
	maxBounces: number, -- max possible bounces
	velocityDecay: number, -- rate of velocity decay upon hitting something
	velocityThreshold: number, -- min velocity before projectile will end its life
	typeId: number, -- unique identifier for the type of projectile
	initialVelocity: number, -- initial velocity of the projectile

	debug: boolean,
}

local Projectiles = {
	["Ball"] = {
		id = "Ball",
		gravityScale = 0.2,
		radius = 2,
		totalTime = 20,
		maxBounces = 20,
		velocityDecay = 0.8,
		velocityThreshold = 5,
		typeId = 1,
		debug = false,
		initialVelocity = 100,
	},
}

return Projectiles
