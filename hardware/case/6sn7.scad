
module 6sn7() {

     $fn = 32;
     mm = 25.4;

     pinl = mm*((3+5/16)-(2+3/4));

     translate( [0, 0, 0]) {
	  % cylinder( h=2.75*mm, d=(1+3/16)*mm);
	  color("black")
	       cylinder( h=0.75*mm, d=(1+5/16)*mm);
	  for( i=[0:7]) {
	       a = (360/8)*i;
		    rotate( [0, 0, a])
	       translate( [17.5/2, 0, -pinl])
			 color("silver")
			 cylinder( h=pinl, d=2);
	  }
     }
     
}
