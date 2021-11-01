//(c) Inne Lemstra

render_3D = true; //if false render 2D for lasercutting.

h_box = 10;
thickness_plexi = 3;
groove_plexi = 1.5;
len_base = 50;

w_plexi = len_base + 2 * groove_plexi;
h_thick = 0.5;
w_thick = 4;

nr_size = 2;

if(render_3D){
    linear_extrude(thickness_plexi)
    make_front_plate();
    cube([w_plexi, h_box, thickness_plexi * 0.8]);
}else{
    make_front_plate();
}

module make_front_plate(){
difference(){
color("aqua"){
square([w_plexi, h_box]);
}

for(idx =[0:2.5:h_box - 2.6]){
    
    color("blue"){
        translate([len_base/2, idx + groove_plexi, 0]){
            square([w_thick, h_thick], center = true);
            translate([w_thick/2 + 2, - nr_size/2,0]){
            text(str(idx), nr_size);
            }
        }
    }
}
}
}