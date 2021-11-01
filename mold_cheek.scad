//(c) Inne Lemstra
/* Based on softrobotics bubble mold v4*/
//has new air inlet system
$fn = 100;

render_bubble = true;
render_bubble_air_inlet = true;
render_bubble_inlet_hole = true;
render_screw_pillars = false;
render_walls_plexi = false;
render_walls_print = false;
render_grooves = false;
render_base = false;

render_bubble_needle_inlet = false;


render_component_central_cross = false;
render_component_pillar = false;
render_component_pillar_cross = false;
render_component_central_tube = false;
render_component_inverse_pillar = false;
render_component_air_inlet = false;

h_box = 10;
thickness_box = 3;

thickness_plexi = 3.2; // how thick the plexiglass is
groove_plexi = 1.5; //how deep the groove is
offset_groove = 10; //space the base extends past plexi walls

//plexiglass walls
ratio_plexi_connect = 0.7; //for the gaps in the backplate
h_plexi_front = 15; //heigth front panel (so it can slide in/out)
h_plexi = 20; //heigth for the rest of the panels

dia_screw = 3.5;
offset_screw = 6;

len_base = 50;
w_base = 50; // unnecesary for now because base is square
h_base = 2;


dia_air_pocket = 30;
h_air_pocket = 1.2; //heigth air pocket


//air inlet parameters
n_inlets = 2; //does not seem to work

dia_coupler = 1;
len_coupler = 4;

len_transition = 2;

dia_supply_tube = 1;
len_supply_tube = 13;
offset_tube_h = dia_supply_tube * 0.40;



w_connector_base = 5;
h_connector_base = 2;   //mayve this should be h_base by default

corner_coord = [[0,0], [0,1], [1,1], [1,0]];


module air_inlet(len_coupler, dia_coupler, len_transition, dia_supply_tube, len_supply_tube ,offset_tube_h,  len_base, h_base){

    difference(){
        union(){
    color("blue"){
        rotate([0,90,0]){
        //supply_tube
            translate([-h_base - offset_tube_h,0,0]){
        //coupler
            cylinder(len_coupler, d = dia_coupler);
            //transision piece
            translate([0, 0 , len_coupler]){
                cylinder(len_transition, d1 = dia_coupler, d2 = dia_supply_tube);
            }
        //supply tube
            cylinder(len_supply_tube, d = dia_supply_tube);
        }
    }
    }
    }
    neg_z_zone = 50; //make sure everything below z axis gets removed
    translate([0,dia_coupler / -2, -neg_z_zone]){
        cube([len_supply_tube* 1.1, dia_coupler * 1.1, h_base +neg_z_zone]);
        }
    
}
}

module bar_connect(width, length, depth){
        union(){
    //move connector under z plane of origin
        translate([0,0, -depth /2]){
            //left most side
            translate([-width, 0,0]) cube([width, length, depth], center = true);
            //middle side
            cube([width, length, depth], center = true);            
            //right most side
            translate([width, ,0]) cube([width, length, depth], center = true);
        }
    }
    
    }
    
module draw_cross(width){
    //draws a 2D cross/plus shape total width is 3 * width
    union(){   
            //left most side
            translate([-width, 0,0]) square([width, width], center = true);
            //middle side
            square([width, width], center = true);
            //midle top
            translate([0, width, 0]) square([width, width], center = true);
            //midle bottom
            translate([0, -width, 0]) square([width, width], center = true);
            
            //right most side
            translate([width, ,0]) square([width, width], center = true);
        }
}
    

module cross_connect(width, depth, taper_size = 0.7, taper_ratio = 0.5){
    
     if(taper_ratio < 1){
        linear_extrude(height = depth * (1 - taper_ratio)) draw_cross(width);
     }
     if(taper_ratio > 0){
        translate([0, 0,depth * (1 - taper_ratio)]){
            linear_extrude(height = depth * taper_ratio, scale = taper_size){
            draw_cross(width);
            }
        }
    }
}


module make_screw_pillars(len_base, dia_screw, offset_screw, h_base, h_box, corner_coord, taper_size = 0.8, taper_ratio = 0.3 ,n = 4){
    translate([0,0,h_base]){
        for(i = [0:n-1]){
        coord_x  = len_base * corner_coord[i][0];
        coord_y  = len_base * corner_coord[i][1];
        // * -2 + [1,1] makes coord 0 (+) and 1 (-)
        corner_offset = (corner_coord[i] * -2 + [1, 1]) * offset_screw;
        translate([coord_x + corner_offset[0], coord_y + corner_offset[1], 0]){
            color("orange"){
                if(!render_component_inverse_pillar){
        cylinder(h_box - h_base, d = dia_screw);
                }else{
                translate([0,0,h_base])
                    cylinder(h_box - h_base, d = dia_screw);
            }
            }
            color("red"){
                if(!render_component_inverse_pillar){
                rotate([0,180,0]) cross_connect(2, h_base, taper_size, taper_ratio);
                }else{
                cross_connect(2, h_base, taper_size, taper_ratio);
             }
            }
        }
            //echo(corner_offset);  
        }
}
}

module make_volume_marks(h_plexi, groove_plexi, len_plexi, w_thick = 4, h_thick = 0.5, nr_size = 2, step_volume = 2.5){
    
    for(idx =[0:step_volume:h_plexi - step_volume + 0.1]){
    
    color("blue"){
        translate([len_plexi/2, idx + groove_plexi, 0]){
            square([w_thick, h_thick], center = true);
            translate([w_thick/2 + 2, - nr_size/2,0]){
            text(str(idx), nr_size);
            }
        }
    }
}

}

if(render_base){
    difference(){
    //ground plate
        cube([len_base, len_base, h_base]);
        translate([len_base / 2, w_base/ 2, -0.1]){
           cross_connect(w_connector_base, h_base + 0.2, taper_size = 1, taper_ratio = 0.5);
        }
        make_screw_pillars(len_base, dia_screw, offset_screw, h_base, h_box,corner_coord, taper_size = 1, taper_ratio = 1);
        
    }
}


//screw locations
if(render_screw_pillars){
for(i = [0:3]){
    coord_x  = len_base * corner_coord[i][0];
    coord_y  = len_base * corner_coord[i][1];
    // * -2 + [1,1] makes coord 0 (+) and 1 (-)
    corner_offset = (corner_coord[i] * -2 + [1, 1]) * offset_screw;
    translate([coord_x + corner_offset[0], coord_y + corner_offset[1], h_base]){
        color("orange"){
    cylinder(h_box - h_base + 0.01, d = dia_screw);
        }
        color("red"){
            cross_connect(2, h_base);
        }
    }
  echo(corner_offset);  
}
}



if(render_bubble){
    if(render_bubble_air_inlet){
        
       // for(i = [0:n_inlet){
        //left inlet
//                    translate([0, len_base / 2 , 0]){
//                        air_inlet(len_coupler, dia_coupler, len_transition, dia_supply_tube, len_supply_tube ,offset_tube_h,  len_base, h_base);
//                    }
         //bottom inlet    
        translate([len_base/2, 0]){rotate([0,0,90]){
            air_inlet(len_coupler, dia_coupler, len_transition, dia_supply_tube, len_supply_tube ,offset_tube_h,  len_base, h_base);
        }}
    }
    
   // }
    
    if(render_bubble_inlet_hole){
        difference(){
            color("green"){
               translate([len_base / 2, len_base / 2,  h_base]){ 
                   cylinder(h_air_pocket, d = dia_air_pocket);      
                }
            }
            //hole to mount seperate inlets
                     //bottom inlet    
        translate([len_base/2, 0, -.01]){rotate([0,0,90]){
            //cylinder( len_coupler + len_transition +len_supply_tube , d= dia_supply_tube);
            #air_inlet(len_coupler, dia_coupler, len_transition, dia_supply_tube, len_supply_tube ,offset_tube_h,  len_base, h_base);
        }}
        }
    }else {
            color("green"){
               translate([len_base / 2, len_base / 2,  h_base]){ 
                   cylinder(h_air_pocket, d = dia_air_pocket);      
                }
            }            
    }
        
      
    
    color("red"){
        //move cross center base
        translate([len_base / 2, w_base/ 2, h_base+ .1]){
            rotate([0, 180, 0]){
            cross_connect(w_connector_base, h_connector_base);
            }
        }
    }
    
    
    //end render_bubble if statement
}


if(render_walls_print){ 
    color("purple"){
        //bruteforce walls enclosure
        //x direction wall, origin
        translate([0, -thickness_box, 0]){
            cube([len_base ,thickness_box, h_box]);
        }
        //y direction wall origin
        translate([-thickness_box, -thickness_box , 0]){
            cube([thickness_box, len_base + 2*thickness_box, h_box]);
        }
        
        //x direction wall oposit
        translate([0, len_base, 0]){
            cube([len_base ,thickness_box, h_box]);
        }
        
    }
    
    color("pink"){
        translate([len_base,0,0]){
            difference(){
            union(){
                //floor plate
                cube([10, len_base, h_base]);
                //origin wall
                translate([0, -thickness_box, 0]){
                    cube([10, thickness_box, h_box]);
                }
                translate([0, len_base, 0]){
                    cube([10 ,thickness_box, h_box]);
                }
            }
            //plexiglass wall
            //move wall a bit into box_wall
            translate([0, -groove_plexi, h_base - groove_plexi]){
                cube([thickness_plexi ,len_base + 2*groove_plexi, h_box]);
            }
            }
        }
        
    }
}


if(render_walls_plexi){
    //render the plexiglass walls for laser cutting
    //panel specific parameter
    len_panel = len_base + 2 * offset_groove;
    //side panel
        
    for(i  = [0,1]){
        translate([(len_panel + 0.01) * i, 0 ,0]){
            
            difference(){
                color("aqua")
                square([len_base + 2* offset_groove, h_plexi]);
                color("red"){
                    translate([offset_groove - thickness_plexi, 0, 0])
                    square([thickness_plexi, h_plexi * ratio_plexi_connect]);
                    translate([len_base + offset_groove, 0,0])
                    square([thickness_plexi, h_plexi_front]);
                }
            }
        }
    }
    //back panel
    translate([(len_panel + 0.01) * 2, 0,0]){
        difference(){
            color("aqua")
            square([len_base + 2* offset_groove, h_plexi]);
            color("red"){
                //place y (both cuts)
            translate([0, h_plexi * ratio_plexi_connect,0]){
                //place left cut x
                translate([offset_groove - thickness_plexi, 0, 0])
                square([thickness_plexi, h_plexi * (1 - ratio_plexi_connect)]);
                //place right cut x
                translate([len_base + offset_groove,0,0])
                square([thickness_plexi, h_plexi * (1 - ratio_plexi_connect)]);
                }
            }
        }
    }
    //front panel
    translate([(len_panel + 0.01) * 3, 0,0]){
        difference(){
            color("aqua")
            square([len_base + 2 * offset_groove, h_plexi_front]);
            //engrave volume markings
            make_volume_marks(h_plexi_front, groove_plexi, len_base + 2*offset_groove);
        }
    }
}

if(render_grooves){
    
    difference(){
        //base extentions
        color("green"){union(){
            // the two side extentions
            translate([0, -offset_groove, 0]) 
                cube([len_base, offset_groove, h_base]);
            translate([0, len_base, 0])
                cube([len_base, offset_groove, h_base]);
            //back extention
            translate([-offset_groove, -offset_groove, 0])
                cube([offset_groove, len_base + 2*offset_groove, h_base]);
            //front extention
            translate([len_base, -offset_groove, 0])
                cube([offset_groove, len_base + 2*offset_groove, h_base]);
        }}
        //grooves
        color("lime"){union(){
            // 2 side grooves
            // lowest y one
            translate([-offset_groove, -thickness_plexi, h_base - groove_plexi])
                cube([len_base + 2 * offset_groove, thickness_plexi, h_base]);
            //highest y one
            translate([-offset_groove, len_base, h_base - groove_plexi])
                cube([len_base + 2 * offset_groove, thickness_plexi, h_base]);
            
            //back groove
            translate([-thickness_plexi, -offset_groove, h_base - groove_plexi])
                cube([thickness_plexi, len_base + 2 * offset_groove, h_base]);
            
            //front groove
            translate([len_base, -offset_groove, h_base - groove_plexi])
                cube([thickness_plexi, len_base + 2 * offset_groove, h_base]);
        }}
    }
}


if(render_component_central_cross){
    color("red"){
        cross_connect(w_connector_base, h_base, taper_size = .8, taper_ratio = .2);
    }       
} 
if(render_component_pillar){
    make_screw_pillars(len_base, dia_screw, offset_screw, h_base, h_box,corner_coord, n=1);
}

if(render_component_pillar_cross){
    cross_connect(2, h_base);
}

if(render_component_central_tube){
    color("red"){
        if(dia_coupler <= w_connector_base){
            cross_connect(w_connector_base, h_base);
            cylinder(h_box + h_base, d = dia_coupler);
        }else {
            rotate([180,0,0])
            cross_connect(w_connector_base, h_base);
            cylinder(h_box, d = dia_coupler);
        }
    }
}

if(render_component_air_inlet){
    
    air_inlet(len_coupler, dia_coupler, len_transition,                 dia_supply_tube, len_supply_tube ,offset_tube_h,  len_base, h_base);
                   
    
}
    