//(c) Inne 28-10-2021
$fn = 50; //detail of round objects

//For the top scafold you need:
//  render_3D
//  render_bolts
//  render_threads
//  render_bubble
//  render_base_corners
//
//For the bottom scafold you need:
//  render_3D
//  render_sites
//  render_threads
//  render_nuts
//  render_led
//  render_cable_lane


render_threads = true;
render_nuts = false;
render_sides = false;
render_led = false;
render_cable_lane = false;
render_bubble = true;
render_bolts = true;
render_base_corners = true;
render_3D = true;

//to make the holes for the nuts, bolts and threads fit.
printer_margin = 0.7;

//dimensions (mm) base (is square in centre)
dim_base = [50, 50, 2]; //l, w, h
r_base_corner = 3; //radius of fillet on base (for the top plate)

//color of part in preview mode
colour = "lime";

d_bubble = 30; //diameter bubble

d_thread = 3 + printer_margin; //m3
dim_nut = [5.5 + printer_margin, 2.30]; // m3 nut measured: dia, thickness
dim_bolt = [5.4 + printer_margin, d_thread ,1.74]; //bolt head: dia_1, dia_2, height
perim_thread = 6 + d_thread; //distance from side (to center thread)

//dimensions side pertrusion for fabric attachment
dim_side = [10, dim_base.y, dim_base.z];
//slot for sewing
dim_slot = [2, dim_side.y * 0.8, dim_side.z]; //w, l, h
r_corner = 3; //radius of fillet on the outer corners 


//The neopixel
dim_led = [9.6, 9.6, 2.67];
dim_led_inner = [5, 9.6, dim_led.z - 1]; //to prevent it from falling trough
dim_cable = [dim_base.x / 2 + dim_side.x, 8, 2];

//print design rules
echo("###please consider the following (\"design rules\")###")
echo("######################################");

echo("layer height between nut and base is ", dim_base.z - dim_nut[1], "mm");
echo("distance nut and top is ", perim_thread - dim_nut[0], "mm");
echo("layer thickness above cable lane is ", dim_base.z - dim_cable.z, "mm");

echo("layer thickness below bolt is ", dim_base.z - dim_bolt.z, "mm")

for(i = [0:2]) echo("######################################");

color(colour)
if(render_3D){
    difference(){
        linear_extrude(dim_base.z)
        make_base();
        if(render_nuts){
            linear_extrude(dim_nut[1])
            make_nut_holes();
        }
        //Hole for LED
        if(render_led){
            linear_extrude(dim_base.z - dim_led_inner.z)
            square([dim_led.x, dim_led.y], center = true);
            translate([0,0, -dim_led_inner.z / 2 + dim_base.z ])
            cube(dim_led_inner, center = true);
        }
        //cable lane
        if(render_cable_lane){
        linear_extrude(dim_cable.z)
        translate([0, -dim_cable.y / 2, 0])
        square([dim_cable.x - dim_side.x / 2, dim_cable.y]);
        }
        
        //sinking in bolt heads
        if(render_bolts){
            translate([0,0, dim_base.z - dim_bolt.z + 0.01])
            make_bolt_holes();
        }
        //rounding base
        if(render_base_corners){
            place_corner(dim_base, [1,1] * r_base_corner, 0)
            linear_extrude(dim_base.z)
            square([1,1] * r_base_corner *2, center = true);
        }
        
        
        
    }
    
    //place round corners and make sure sinked bolt still fits
    if(render_base_corners){
        difference(){
            place_corner(dim_base, [1,1] * r_base_corner, 
                                 r_base_corner * 2)
            rotate([0,0, 90])
            linear_extrude(dim_base.z)
            make_fillet(r_base_corner);
            
        //sinking in bolt heads again
        if(render_bolts){
            translate([0,0, dim_base.z - dim_bolt.z + 0.01])
            make_bolt_holes();
        }
            
    }
}
}else{
    make_base();
}


module make_base(){
    
    difference(){
    union(){
        square([dim_base.x, dim_base.y], center = true);
        
        if(render_sides){
            for(i = [0:1]){
                mirror([i, 0, 0]) //why this mirrors in x, no idea 
                translate([-dim_base.x /2 - dim_side.x / 2, 0, 0])
                make_side_attach();
            }
        }
    }
    
    if(render_bubble){
        circle(d=d_bubble);
    }
        
    if(render_threads){make_thread_holes();}
    //!render_3D){//not 3D i.e. 2D (lasercutter)
    if(render_nuts && !render_3D){make_nut_holes();}
    
    if(render_led && !render_3D)square([dim_led.x,dim_led.y], center = true);
    if(render_cable_lane && !render_3D){
        //needs to be engraved so can't overlap any cuts.
        translate([dim_led.x / 2 + 0.01, -dim_cable.y / 2, 0])
        square([dim_cable.x - dim_led.x / 2 
                    - dim_side.x / 2 - dim_slot.x / 2 - 0.01,
                dim_cable.y]);
    }
    }
    
    if(render_threads && render_nuts && !render_3D){
        //otherwise the circles disapear in the nut hexagon shape
        if(render_threads){make_thread_holes();} 
    }
    

    

    
}

module make_thread_holes(){
    place_corner(dim_base, [d_thread, d_thread], perim_thread) circle(d = d_thread);
}

module make_nut_holes(){
    place_corner(dim_base, [dim_nut.x, dim_nut.x], perim_thread) circle(d = dim_nut.x, $fn=6);
}

module make_bolt_holes(){
    place_corner(dim_base, [dim_nut.x, dim_nut.x], perim_thread)
    cylinder(h=dim_bolt.z, d1= dim_bolt.y, d2= dim_bolt.x);
}
module place_corner(dim_base, dim_object, offset_perim){
    //origin child should be [0,0]
    for(x = [0:1], y = [0:1]){
     
     mirror([x,0,0]) //don't mirror x and y at same time
     mirror([0,y,0])
     translate([
               -dim_base.x/2 + dim_object.x * 0 + offset_perim / 2,
                dim_base.y/2 - dim_object.y * 0 - offset_perim / 2,
               0])
     children(0);  
    }
    
}

module make_side_attach(){
    
    difference(){
    union(){
        //make the side base
        square([dim_side.x, dim_side.y - r_corner * 2], center= true);
        translate([-dim_side.x / 2 + r_corner, dim_side.y / 2 - r_corner,0]){
        rotate([0, 0, 90]) make_fillet(r_corner);
        square([dim_side.x - r_corner, r_corner]); //magicly works without          
                                                   //translate, but nice horse
        }
        translate([-dim_side.x / 2 + r_corner, -dim_side.y / 2 + r_corner,0]){
        rotate([0, 0, 180]) make_fillet(r_corner);
        translate([0,-r_corner,0])
        square([dim_side.x - r_corner, r_corner]);
        }
    }
    make_slot();
    }
    
    
}

module make_slot(){
    //rectangular hole in side to sew print into fabric
    //-dim_slot.x because that space gets occupied by filled
    square([dim_slot.x, dim_slot.y - dim_slot.x], center = true);
    for(x = [0:1], y = [0:1]){
        mirror([x,0,0])
        mirror([0,y,0])
        translate([0, (dim_slot.y - dim_slot.x) /2, 0])
        make_fillet(dim_slot.x / 2);
    }
}

module make_fillet(r){
    //2D quarter circle in +x and +y
    intersection(){
        circle(r=r);
        square([r,r]);
        }
}