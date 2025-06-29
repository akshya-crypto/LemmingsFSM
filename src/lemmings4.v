module lemmings(
    input clk,
    input areset,    
    input bump_left,
    input bump_right,
    input ground,
    input dig,
    output walk_left,
    output walk_right,
    output aaah,
    output digging ); 
    
    parameter LEFT=3'b000, RIGHT=3'b001, DIG_L=3'b010, DIG_R=3'b011, FALL_L=3'b100, FALL_R=3'b101, SPLAT=3'b110;
    reg [2:0] state,next_state;
    reg [6:0]count;
    
    always@(*)begin
        case(state)
            LEFT: begin
                if(!ground) next_state=FALL_L;
                else if(dig) next_state=DIG_L;
                else if(bump_left) next_state=RIGHT;
                else next_state=LEFT;
            end
            RIGHT: begin
                if(!ground) next_state=FALL_R;
                else if(dig) next_state=DIG_R;
                else if(bump_right) next_state=LEFT;
                else next_state=RIGHT;
            end
            FALL_L: begin
                if(ground )begin
                    if(count>19) next_state=SPLAT;
                    else next_state=LEFT;
                end
                else next_state=FALL_L;
            end
            FALL_R: begin
                if(ground)begin
                    if(count>19) next_state=SPLAT;
                    else next_state=RIGHT;
                end
                else next_state=FALL_R;
            end
            DIG_L: begin
                if(!ground) next_state=FALL_L;
                else next_state=DIG_L;
            end
            DIG_R: begin
                if(!ground) next_state=FALL_R;
                else next_state=DIG_R;
            end
            SPLAT: next_state=SPLAT;
        endcase
    end
    
    always@(posedge clk or posedge areset) begin
        if(areset) begin
            state<=LEFT;
            
        end
        
        else begin
            state<=next_state;
            if((state==FALL_L)||(state==FALL_R))
                count<=count+1;
            else
                count<=0;
        end
    end
    
    assign walk_left= (state==LEFT);
    assign walk_right=(state==RIGHT);
    assign digging= ((state==DIG_L)||(state==DIG_R));
    assign aaah= ((state==FALL_L)||(state==FALL_R));
        
                

endmodule


module test_lemmings();
    reg clk,bump_left,bump_right,ground, dig,areset;
    wire walk_left,walk_right,digging,aaah;
    
      lemmings uut(.clk(clk),.areset(areset),.bump_left(bump_left),.bump_right(bump_right),.dig(dig),.ground(ground),
                 .walk_left(walk_left),.walk_right(walk_right),.aaah(aaah),.digging(digging));
    initial clk=0;
    always begin
        #5 clk=~clk;
    end
    initial begin
        $monitor($time,"areset=%b,bump_right=%b,bump_left=%b,ground=%b,dig=%b,digging=%b,walk_left=%b,walk_right=%b,aaah=%b"
                 ,areset,bump_right,bump_left,ground,dig,digging,walk_left,walk_right,aaah);
        areset = 1; bump_right = 0; bump_left = 0; ground = 1; dig = 0;
        #10 areset = 0;

        
        #10 ground = 0;  
        #20 ground = 1;  
        #10 bump_left = 1;  
        #10 dig = 1;        
        #10 ground = 0;     
        #100;              
        #10 areset = 1;
        #10 areset = 0;

        #50 $finish;
    end
endmodule