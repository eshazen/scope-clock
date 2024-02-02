// Grills
$fa=.5;$fs=.5;
mm=25.4;

HoleSize=4;    // inches
EdgeWidth=.3;  // inches
Webb=1 ;        //mm
Q=1;
Perf=0.17;

//Grill();
module Grill(H=HoleSize,T=Webb,W=EdgeWidth,DH=2.75,Th=Q)
{
    
    module webb()
    {
        for(x=[-H/2*mm:Perf*mm:H/2*mm]){
            //echo(x);
            translate([x,0,(Th+.2)/2])cube([T,H*mm+2,Th+.2],true);
            translate([0,x,(Th+.2)/2])cube([H*mm+2,T,Th+.2],true);
        }
    }
    intersection(){
        webb();
        cylinder(d=H*mm,Th);
    }
    difference(){
        cylinder(d=H*mm+W*mm*2,Th);
        translate([0,0,-.1])cylinder(d=H*mm,Th+.2);
        if(DH>0)for(d=[0:1:2]){
            rotate([0,0,d*360/3])translate([H*mm/2+W*mm/2,0,-.1])cylinder(d=DH,Th+0.2);
        }
    }
}

//Standoff(H=18,T=1,W=.7*mm,D=4.52*mm,C=70);
module Standoff(H,T,W,D,C)
{
    
    module slot()
    {
        hull(){
            translate([D/2-.4,0,5])rotate([0,90,0])cylinder(d=2.5,2.5);
            translate([D/2-.1,4,H-4])rotate([0,90,0])cylinder(d=2.5,2.5);
        }
    }
    
    
    difference(){
        union(){
            cylinder(d=D+T*2,H);
            cylinder(d=D+W,2.25);
        }
        translate([0,0,-.1])cylinder(d=D,H+.2);
        for(a=[0:1:C])rotate([0,0,a*360/C])slot();
        if(W>6){
            for(d=[0:1:2]){
                rotate([0,0,d*360/3])translate([D/2+W*.325,0,-.1])cylinder(d=2.75,2.5+0.2);
            }
        }
    }
    
    
    
}

// echo(40/mm);
// echo(125/mm);

//color("blue")cube([1,38,1],true);
//color("blue")cube([125,1,1],true);
//LampGrill(DrillHole=0);
module LampGrill(D=4.9-.4,EdgeWidth=.2,DrillHole=0)
{
    Q=1;

    difference(){
        union(){
            Grill(H=D,T=.65 ,W=EdgeWidth,DH=0,Th=Q);
            cylinder(d=1.8*mm,Q);
        }
        translate([0,0,-.1])cylinder(d=1.57*mm,Q+.2);
    }
}


VacuumeOutlet(print=true);
module VacuumeOutlet(print=false)
{
    D=56.06;
    Xd=17;
    
    module offset()
    {
        
        //color("blue")translate([-Xd/2,0,0])cube([D+4+Xd,1,1],true);
        difference(){
            
            union(){
                translate([-Xd/2,0,0])cylinder(d=D+Xd+5,2);
                cylinder(d=D+5,10);
            }
            translate([0,0,-.1])cylinder(d=D+.6,11);
        }

    }
    
    
    if(print){
        offset();
        translate([-Xd/2+70,40,0])Standoff(24,T=2,W=2,D=D+Xd+1,C=40);
        translate([-Xd/2,80,0])Grill(H=(D+Xd+1)/mm,T=1,W=2/mm,DH=0,Th=2);
    }else{
        offset()
        #translate([-Xd/2,0,-25])Standoff(24,T=2,W=2,D=D+Xd+1,C=40);
        translate([-Xd/2,0,-28])Grill(H=(D+Xd+1)/mm,T=1,W=2/mm,DH=0,Th=2);
    }

}