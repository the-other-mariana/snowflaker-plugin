plugin simpleObject Snowflake_Mesh
name: "Snowflake"
classID:#(0x2d067ec, 0x164da1ad)
category:"Snowflaker Plugin"
(
	parameters main rollout:SF_Params
	(
		P_Radius type:#worldUnits ui:UI_Radius	default:10
		P_Height type:#worldUnits ui:UI_Height	default:4
		P_Spikes type:#integer ui:UI_Spikes	default:6
		P_Thick type:#float ui: UI_Thick default: 2.0
		
		P_SpSize type: #float ui: UI_SpSize default: 50.0
		P_SpSeg type: #integer ui: UI_SpSeg default: 10
		
		P_SSpSeg type: #integer ui: UI_SSpSeg default: 4
		P_SSpSize type: #float ui: UI_SSpSize default: 13.0
		P_SizeVar type:#float ui: UI_SizeVar default: 0.0
		P_Skip type: #integer ui: UI_Skip default: 1
		
		P_Freq type: #integer ui: UI_Freq default: 60
		P_Ampl type: #float ui: UI_Ampl default: 0.3
		
		P_OnlyTip type: #boolean ui: OnlyTip_cb default: false
		P_AngleVar type:#float ui: UI_AngleVar default: 0.0
	)
	
	rollout SF_Params "Parameters"
	(
		group "General Parameters"
		(
			spinner UI_Radius "Radius" type:#worldUnits range:[0, 1000, 10]
			spinner UI_Height "Height" type:#worldUnits range:[-1000, 1000, 4]
			spinner UI_Spikes "Spikes" type:#integer range:[3, 27, 6]
			spinner UI_Thick "Thickness" type:#float range:[0.1, 30.0, 2.0]
		)
		group "Spikes"
		(
			spinner UI_SpSize "Spike Size" type:#float range:[20.0, 1000.0, 50.0]
			spinner UI_SpSeg "Spike Segments" type:#integer range:[1, 1000, 10]
		)
		
		group "Sub-spikes"
		(
			spinner UI_SSpSeg "Segments" type:#integer range:[1, 100, 4]
			spinner UI_SSpSize "Size" type:#float range:[1.0, 1000.0, 13.0]
			slider UI_SizeVar "Size Variation" orient:#horizontal ticks:10 range:[0.0,4.0,0.0]
			spinner UI_Skip "Skip Degree" type:#integer range:[1, 5, 1]
			
			dropdownlist shape_dd "Shape" items:#("Decay", "Growth", "Sinusoidal", "Constant")
			spinner UI_Freq "Frequency" type:#integer range:[1, 1000, 60]
			spinner UI_Ampl "Impact" type:#float range:[0.0, 0.9, 0.3]
			
			checkbox OnlyTip_cb "Only In Tip"
			slider UI_AngleVar "Angle Variation" orient:#horizontal ticks:10 range:[0.0,20.0, 0.0]
		)
		
		global shapeOp = 1
		
		on shape_dd selected i do
		(
			shapeOp = i
			format "You chose %! \n" shapeOp
		)
	)
	
	fn greetings msg=
	(
		print(msg)
	)
	
	fn createSpike p0 p1 size deg pts segs=
	(
		midpoint = [p0.x + p1.x, p0.y + p1.y, p0.z + p1.z]
		midpoint = midpoint * 0.5
		axis = [0, 0, 1]
		axis = normalize axis
		
		vect1 = p0 - midpoint
		q = quat deg axis
		vect2 = vect1 * q
		vect2 = normalize vect2
		
		spikePos = (vect2 * size) + midpoint
		newSpike1 = spikePos
		newSpike2 = [newSpike1.x, newSpike1.y, P_Height]
		
		Append pts newSpike1
		Append pts newSpike2
		
		-- spike segments points
		factor = 1.0 / segs
		
		
		dir1 = newSpike1 - p0
		dist1 = distance newSpike1 p0
		dir1 = normalize dir1
		
		--c1 = Cone radius1:0.5 radius2:0 height:dist1 pos:p0
		--c1.dir = dir1
		
		dir2 = newSpike1 - p1
		dist2 = length dir2
		dir2 = normalize dir2
		
		--c2 = Cone radius1:0.5 radius2:0 height:dist2 pos:p1
		--c2.dir = dir2
		
		for i in 1 to (segs - 1) by 1 do
		(
			temp1Bottom = p0 + ((factor * i * dist1) * dir1)
			temp1Top = [temp1Bottom.x, temp1Bottom.y, P_Height]
			Append pts temp1Bottom
			Append pts temp1Top
			--print(temp1)
			
			temp2Bottom = p1 + ((factor * i * dist2) * dir2)
			temp2Top = [temp2Bottom.x, temp2Bottom.y, P_Height]
			Append pts temp2Bottom
			Append pts temp2Top
		)
		
		--return sp_pts
	)
	
	on buildMesh do
	(
		vertices = #()
		faces = #()
		
		P_Sides = P_Spikes * 2
		step_angle = 360.0 / P_Sides
		xPos = 0.0
		yPos = 0.0
		zPos = 0.0
		
		-- inner ring points
		-- order:
		-- 1) outside bottom ring (1 - (1*sides))
		-- 2) outside top ring ((1*sides+1) - (2*sides))
		-- 3) inside bottom ring ((2*sides+1) - (3*sides))
		-- 4) inside top ring ((3*sides+1) - (4*sides))
		for k in 1 to (2) by 1 do
		(
			for j in 1 to (2) by 1 do
			(
				
				for i in 1 to (P_Sides) by 1 do
				(
					radius = P_Radius - (k - 1) * P_Thick
					xPos = radius * cos(((i - 1) * step_angle) + (step_angle/2.0)) 
					yPos = radius * sin(((i - 1) * step_angle) + (step_angle/2.0)) 
					
					zPos = (j - 1) * P_Height
					vert = [xPos, yPos, zPos]
					Append vertices vert
					
					
				)
			)
		)
		
		-- main spike points
		sp_pts = #()
		for i in 1 to (P_Sides) by 1 do
		(
			if (mod i 2) == 1 then
			(
				p0 = vertices[i]
				p1 = vertices[i + 1]
				--format "% and % \n" (i) (i + 1)
				
				createSpike p0 p1 P_SpSize -90.0 sp_pts P_SpSeg
			)
		)
		
		for i in 1 to (sp_pts.count) by 1 do
		(
			Append vertices sp_pts[i]
		)
		
		-- sub spike points
		counter = 0
		ssp_pts = #()
		index = 1
		ds = (P_SSpSize / 2.0) / P_SpSeg
		minimum = 1
		modNum = P_Skip * 2
		
		if P_OnlyTip == true then minimum = (P_SpSeg / 2.0 as integer) else minimum = 1
		
		for j in 1 to (P_Spikes) by 1 do
		(
			if j == 1 then
			(
				index += (P_Sides * 4) + 2
			) else
			(
				index += ((P_SpSeg - 1) * 4) + 2
			)
			for i in 1 to (P_SpSeg - 2) by 1 do
			(
				--index += 2
				--format "% and % \n" (index + ((i - 1)*4)) (index + ((i - 1)*4) + 4)
				if (mod i modNum) == 1 and i >= minimum then
				(
					p0_1 = vertices[(index + ((i - 1)*4))]
					p1_1 = vertices[(index + ((i - 1)*4) + 4)]
					
					p0_2 = vertices[(index + ((i - 1)*4)) + 2]
					p1_2 = vertices[(index + ((i - 1)*4) + 4) + 2]
					
					delta = 0
					size = P_SSpSize
					
					if shapeOp == 1 then
					(
						size = P_SSpSize - (ds * i)
					)
					if shapeOp == 2 then
					(
						size = (P_SSpSize / 2.0) + 2*(ds * i)
					)
					if shapeOp == 3 then
					(
						size = P_SSpSize + (P_SSpSize * sin(P_Freq*i) * P_Ampl)
					)
					if shapeOp == 4 then
					(
						size = P_SSpSize
					)
					
					randSize = random (-P_SizeVar) P_SizeVar
					randAngle = random (-P_SizeVar) P_AngleVar
					
					createSpike p0_1 p1_1 (size + randSize) (-120.0 + randAngle) ssp_pts P_SSpSeg
					
					randSize = random (-P_SizeVar) P_SizeVar
					randAngle = random (-P_SizeVar) P_AngleVar
					
					createSpike p0_2 p1_2 (size + randSize) (120.0 + randAngle) ssp_pts P_SSpSeg
					
					counter += 2
				)
			)
		)
		
		if counter == 0 then return messageBox "No Sub-spikes could be made. Increase segments!" title:"No Sub-spikes" beep:true
		
		for i in 1 to (ssp_pts.count) by 1 do
		(
			Append vertices ssp_pts[i]
		)
		
		-- create faces once vertices are ready
		
		-- inner ring faces: top + bottom
		smooth_g = #()
		exc = 0
		for j in 1 to 2 by 1 do
		(
			exc = 0
			for i in 1 to (P_Sides) by 1 do
			(
				if i == P_Sides then
				(
					exc = P_Sides
				)
				sg = 2^(j - 1)
				v1 = (i + 1 - exc) + ((j - 1) * P_Sides)
				v2 = i + ((j - 1) * P_Sides)
				v3 = ((P_Sides * 2) + i) + ((j - 1) * P_Sides)
				
				v = [v1, v2, v3]
				if (j == 2) then v = [v3, v2, v1]
				
				Append faces v
				Append smooth_g [faces.count, sg]
				
				v1 = ((P_Sides * 2) + i) + ((j - 1) * P_Sides)
				v2 = ((P_Sides * 2) + (i + 1) - exc) + ((j - 1) * P_Sides)
				v3 = (i + 1 - exc) + ((j - 1) * P_Sides)
				
				v = [v1, v2, v3]
				if (j == 2) then v = [v3, v2, v1]
				
				Append faces v
				Append smooth_g [faces.count, sg]
			)
		)
		
		-- side ring faces
		exc = 0
		base = 0
		sg = 0
		sg_index = 1
		for j in 1 to 2 by 1 do
		(
			exc = 0
			base += 1
			for i in 1 to (P_Sides) by 1 do
			(
				if i == P_Sides then
				(
					exc = P_Sides
				)
				if ((j == 1) and (mod i 2 == 0)) or (j == 2) then
				(
					if j == 2 then sg = 2^(j)
					if j == 1 then
					(
						sg_index += 1
						sg = 2^(j + 2)
					)
					
					v1 = (P_Sides * (base - 1)) + i 
					v2 = (P_Sides * (base)) + i 
					v3 = (P_Sides * (base)) + (i + 1) - exc
					
					v = [v1, v2, v3]
					if (j == 1) then v = [v3, v2, v1]
					Append faces v
					Append smooth_g [faces.count, sg]
					
					v1 = (P_Sides * (base)) + (i + 1) - exc 
					v2 = (P_Sides * (base - 1)) + (i + 1) - exc 
					v3 = (P_Sides * (base - 1)) + i
					
					v = [v1, v2, v3]
					Append faces v
					if (j == 1) then v = [v3, v2, v1]
					Append smooth_g [faces.count, sg]
				)
			)
			base += 1
		)
		
		-- top and bottom main spike faces
		index = 0
		sg_index += 3
		sp_sg = sg_index
		sg = 0
		for j in 1 to (P_Spikes) by 1 do
		(
			if j == 1 then
			(
				index += (P_Sides * 4) + 2
			) else
			(
				index += ((P_SpSeg - 1) * 4) + 2
			)
			for t in 0 to 1 by 1 do
			(
				sg = 2^(t)
				for i in 0 to (P_SpSeg - 1) by 1 do
				(
					
					if i == 0 then
					(
						v1 = index + ((i) * 4) + 3 + t
						v2 = index + ((i) * 4) + 1 + t
						v3 = ((j * 2) - 1) + P_Sides * (t)
						v = [v1, v2, v3]
						
						if t == 1 then v = [v3, v2, v1]
						Append faces v
						Append smooth_g [faces.count, sg]
						
						v1 = ((j * 2) - 1) + P_Sides * (t)
						v2 = (j * 2) + P_Sides * (t)
						v3 = index + ((i) * 4) + 3 + t
						v = [v1, v2, v3]
						
						if t == 1 then v = [v3, v2, v1]
						Append faces v
						Append smooth_g [faces.count, sg]
					) 
					if (i > 0 and i < (P_SpSeg - 1)) then
					(
						v1 = index + ((i - 1) * 4) + 7 + t
						v2 = index + ((i - 1) * 4) + 5 + t
						v3 = index + ((i - 1) * 4) + 1 + t
						v = [v1, v2, v3]
						
						if t == 1 then v = [v3, v2, v1]
						Append faces v
						Append smooth_g [faces.count, sg]
						
						v1 = index + ((i - 1) * 4) + 1 + t
						v2 = index + ((i - 1) * 4) + 3 + t
						v3 = index + ((i - 1) * 4) + 7 + t
						v = [v1, v2, v3]
						
						if t == 1 then v = [v3, v2, v1]
						Append faces v
						Append smooth_g [faces.count, sg]
					)
					if i == (P_SpSeg - 1) then
					(
						v1 = index + ((i - 1) * 4) + 3 + t
						v2 = index - 1 + t
						v3 = index + ((i - 1) * 4) + 1 + t
						v = [v1, v2, v3]
						
						if t == 1 then v = [v3, v2, v1]
						Append faces v
						Append smooth_g [faces.count, sg]
					)
				)
			)
		)
		
		-- side faces main spike
		sg = 0
		index = 0
		for j in 1 to (P_Spikes) by 1 do
		(
			
			if j == 1 then
			(
				index += (P_Sides * 4) + 2
			) else
			(
				index += ((P_SpSeg - 1) * 4) + 2
			)
			sg = 2^(j + 3)
			for t in 0 to 1 by 1 do
			(
				for i in 0 to (P_SpSeg - 1) by 1 do
				(
					if ((mod i modNum) != 1 or i < minimum or i == (P_SpSeg - 1)) then
					(
						if i == 0 then
						(
							v1 = index + ((i) * 4) + 1 + (t * 2)
							v2 = index + ((i) * 4) + 2 + (t * 2)
							v3 = ((j * 2) - 1) + P_Sides + t
							v = [v1, v2, v3]
							
							if t == 1 then v = [v3, v2, v1]
							Append faces v
							Append smooth_g [faces.count, sg]
							
							v1 = ((j * 2) - 1) + P_Sides + t
							v2 = ((j * 2) - 1) + t
							v3 = index + ((i) * 4) + 1 + (t * 2)
							v = [v1, v2, v3]
							
							if t == 1 then v = [v3, v2, v1]
							Append faces v
							Append smooth_g [faces.count, sg]
						)
						if (i > 0 and i < (P_SpSeg - 1)) then
						(
							v1 = index + ((i - 1) * 4) + 5 + (t * 2)
							v2 = index + ((i - 1) * 4) + 6 + (t * 2)
							v3 = index + ((i - 1) * 4) + 2 + (t * 2)
							v = [v1, v2, v3]
							
							if t == 1 then v = [v3, v2, v1]
							Append faces v
							Append smooth_g [faces.count, sg]
							
							v1 = index + ((i - 1) * 4) + 2 + (t * 2)
							v2 = index + ((i - 1) * 4) + 1 + (t * 2)
							v3 = index + ((i - 1) * 4) + 5 + (t * 2)
							v = [v1, v2, v3]
							
							if t == 1 then v = [v3, v2, v1]
							Append faces v
							Append smooth_g [faces.count, sg]
						)
						if i == (P_SpSeg - 1) then
						(
							v1 = index + ((i - 1) * 4) + 2 + (t * 2)
							v2 = index
							v3 = index - 1
							v = [v1, v2, v3]
							
							if t == 1 then v = [v3, v2, v1]
							Append faces v
							Append smooth_g [faces.count, sg]
							
							v1 = index + ((i - 1) * 4) + 2 + (t * 2)
							v2 = index + ((i - 1) * 4) + 1 + (t * 2)
							v3 = index - 1
							v = [v1, v2, v3]
							
							if t == 1 then v = [v3, v2, v1]
							Append faces v
							Append smooth_g [faces.count, sg]
						)
					)
				)
			)
		)
		
		-- sub spike faces top and bottom and sides
		index = 0
		sp_index = 0
		per_sp = int(counter / P_Spikes)
		per_side = int(per_sp / 2.0)
		v_sp =  (4 * (P_SSpSeg - 1) + 2)
		sg_2 = 0
		k = 0
		
		for j in 1 to (P_Spikes) by 1 do
		(
			if j == 1 then
			(
				index += (P_Sides * 4) + (4 * P_Spikes  * (P_SpSeg - 1)) + (P_Spikes * 2) + 2
				sp_index += (P_Sides * 4) + 2
			) else
			(
				index += (per_sp) * (4 * (P_SSpSeg - 1) + 2)
				sp_index += ((P_SpSeg - 1) * 4) + 2
			)
			k = 0
			sp_sg += 1
			for seg in 1 to (P_SpSeg - 2) by 1 do
			(
				if (mod seg modNum) == 1 and seg >= minimum then
				(
					k += 1
					-- per side
					for s in 0 to 1 by 1 do
					(
						-- its neighbor
						for t in 0 to 1 by 1 do
						(
							-- top and bottom
							sg = 2^(t)
							sg_2 = 2^(j + 3)
							for i in 0 to (P_SSpSeg - 1) by 1 do
							(
								if i == 0 then
								(
									-- top and bottom
									v1 = index + ((i) * 4) + 3 + t + (s * v_sp) + (2 * (k - 1) * v_sp)
									v2 = index + ((i) * 4) + 1 + t + (s * v_sp) + (2 * (k - 1) * v_sp)
									v3 = sp_index + 1 + t + ((seg - 1) * 4) + (s * 2)
									v = [v1, v2, v3]
									
									if t != s then v = [v3, v2, v1]
									Append faces v
									Append smooth_g [faces.count, sg]
									
									v1 = sp_index + 1 + t + ((seg - 1) * 4) + (s * 2)
									v2 = sp_index + 1 + t + ((seg) * 4) + (s * 2)
									v3 = index + ((i) * 4) + 3 + t + (s * v_sp) + (2 * (k - 1) * v_sp)
									v = [v1, v2, v3]
									
									if t != s then v = [v3, v2, v1]
									Append faces v
									Append smooth_g [faces.count, sg]
									
									-- sides
									v1 = sp_index + 2 + (t * 4) + ((seg - 1) * 4) + (s * 2)
									v2 = sp_index + 1 + (t * 4) + ((seg - 1) * 4) + (s * 2)
									v3 = index + ((i) * 4) + 1 + (t * 2) + (s * v_sp) + (2 * (k - 1) * v_sp)
									v = [v1, v2, v3]
									
									if t != s then v = [v3, v2, v1]
									Append faces v
									Append smooth_g [faces.count, sg_2]
									
									v1 = index + ((i) * 4) + 1 + (t * 2) + (s * v_sp) + (2 * (k - 1) * v_sp)
									v2 = index + ((i) * 4) + 2 + (t * 2) + (s * v_sp) + (2 * (k - 1) * v_sp)
									v3 = sp_index + 2 + (t * 4) + ((seg - 1) * 4) + (s * 2)
									v = [v1, v2, v3]
									
									if t != s then v = [v3, v2, v1]
									Append faces v
									Append smooth_g [faces.count, sg_2]
								)
								if i > 0 and i < (P_SSpSeg - 1) then
								(
									-- top and bottom
									v1 = index + ((i - 1) * 4) + 7 + t + (s * v_sp) + (2 * (k - 1) * v_sp)
									v2 = index + ((i - 1) * 4) + 5 + t + (s * v_sp) + (2 * (k - 1) * v_sp)
									v3 = index + ((i - 1) * 4) + 1 + t + (s * v_sp) + (2 * (k - 1) * v_sp)
									v = [v1, v2, v3]
									
									if t != s then v = [v3, v2, v1]
									Append faces v
									Append smooth_g [faces.count, sg]
									
									v1 = index + ((i - 1) * 4) + 1 + t + (s * v_sp) + (2 * (k - 1) * v_sp)
									v2 = index + ((i - 1) * 4) + 3 + t + (s * v_sp) + (2 * (k - 1) * v_sp)
									v3 = index + ((i - 1) * 4) + 7 + t + (s * v_sp) + (2 * (k - 1) * v_sp)
									v = [v1, v2, v3]
									
									if t != s then v = [v3, v2, v1]
									Append faces v
									Append smooth_g [faces.count, sg]
									
									-- sides
									v1 = index + ((i - 1) * 4) + 2 + (t * 2) + (s * v_sp) + (2 * (k - 1) * v_sp)
									v2 = index + ((i - 1) * 4) + 1 + (t * 2) + (s * v_sp) + (2 * (k - 1) * v_sp)
									v3 = index + ((i - 1) * 4) + 5 + (t * 2) + (s * v_sp) + (2 * (k - 1) * v_sp)
									v = [v1, v2, v3]
									
									if t != s then v = [v3, v2, v1]
									Append faces v
									Append smooth_g [faces.count, sg_2]
									
									v1 = index + ((i - 1) * 4) + 5 + (t * 2) + (s * v_sp) + (2 * (k - 1) * v_sp)
									v2 = index + ((i - 1) * 4) + 6 + (t * 2) + (s * v_sp) + (2 * (k - 1) * v_sp)
									v3 = index + ((i - 1) * 4) + 2 + (t * 2) + (s * v_sp) + (2 * (k - 1) * v_sp)
									v = [v1, v2, v3]
									
									if t != s then v = [v3, v2, v1]
									Append faces v
									Append smooth_g [faces.count, sg_2]
								)
								if i == (P_SSpSeg - 1) then
								(
									-- top and bottom
									v1 = index + ((i - 1) * 4) + 3 + t + (s * v_sp) + (2 * (k - 1) * v_sp)
									v2 = index - 1 + t + (s * v_sp) + (2 * (k - 1) * v_sp)
									v3 = index + ((i - 1) * 4) + 1 + t + (s * v_sp) + (2 * (k - 1) * v_sp)
									v = [v1, v2, v3]
									
									if t != s then v = [v3, v2, v1]
									Append faces v
									Append smooth_g [faces.count, sg]
									
									-- sides
									v1 = index + ((i - 1) * 4) + 2 + (t * 2) + (s * v_sp) + (2 * (k - 1) * v_sp)
									v2 = index + ((i - 1) * 4) + 1 + (t * 2) + (s * v_sp) + (2 * (k - 1) * v_sp)
									v3 = index - 1 + (s * v_sp) + (2 * (k - 1) * v_sp)
									
									v = [v1, v2, v3]
									
									if t != s then v = [v3, v2, v1]
									Append faces v
									Append smooth_g [faces.count, sg_2]
									
									v1 = index - 1 + (s * v_sp) + (2 * (k - 1) * v_sp)
									v2 = index + (s * v_sp) + (2 * (k - 1) * v_sp)
									v3 = index + ((i - 1) * 4) + 2 + (t * 2) + (s * v_sp) + (2 * (k - 1) * v_sp)
									
									v = [v1, v2, v3]
									
									if t != s then v = [v3, v2, v1]
									Append faces v
									Append smooth_g [faces.count, sg_2]
								)
							)
						)
					)
				)
				
			)
		)
		
		setMesh mesh verts:vertices faces:faces
		
		for i in 1 to (smooth_g.count) by 1 do
		(
			setFaceSmoothGroup mesh ((smooth_g[i])[1]) ((smooth_g[i])[2])
		)
		
	)
	
	tool create
	(
		on mousePoint click do
		(
			case click of
			(
				1: nodeTM.translation = gridPoint
				3: #stop
			)
		)
		on mouseMove click do
		(
			case click of
			(
				-- put P_Radius when ready
				2: P_Radius = gridDist.x
				3: P_Height = gridDist.z
			)
		)
	)
	
	
)


