using Distributions


surname_dict = Dict("name"=>"surname","type"=>"freq","char_range"=>"alpha",
         "select_prob"=>0.09,"depend"=>"culture","depend_prob"=>1.00,
      # 'misspell_file':'data'+os.sep+'surname-misspell.tbl',
    "misspell_prob"=>0.30,"ins_prob"=>0.10,"del_prob"=>0.10,"sub_prob"=>0.35,
    "trans_prob"=>0.04,"val_swap_prob"=>0.02,"wrd_swap_prob"=>0.02,
    "spc_ins_prob"=>0.01,"spc_del_prob"=>0.02,"miss_prob"=>0.02,"new_val_prob"=>0.02,
    "pho_prob"=>0.30,"ocr_prob"=>0.01,"ocr_fail_prob"=>0.05,"ocr_ins_sp_prob"=>0.03,"ocr_del_sp_prob"=>0.03)

single_typo_prob = Dict("same_row"=>0.40,
                        "same_col"=>0.30)

error_type_distribution = Dict("typ" => 0.3,
                        "pho" => 0.3,
                        "ocr" => 0.4)

prob_names = ["ins_prob","del_prob","sub_prob","trans_prob","val_swap_prob",
            "wrd_swap_prob","spc_ins_prob","spc_del_prob","miss_prob",
            "misspell_prob","new_val_prob"]

string_lowercase ="abcdefghijklmnopqrstuvwxyz"



function error_position(inputstring::AbstractString, offset::Integer)

    str_len = length(inputstring)
    max_return_pos = str_len - 1 + offset

    if str_len==0
        return nothing
    end

    mid_pos = (str_len + offset) / 2 + 1
    random_pos = rand(Normal(float(mid_pos),1.0,))
    random_pos = max(0,Int(round(random_pos)))

    #print(random_pos,":", max_return_pos)
    return min(random_pos, max_return_pos)

end

error_position("james",0)



function error_character(input_char::Char, char_range::AbstractString)

        rows = Dict{Char,AbstractArray}()
        cols = Dict{Char,AbstractArray}()

        rows['a']=['s']
        rows['b']=['v','n']
        rows['c']=['x','v']
        rows['d']=['s','f']
        rows['e']=['w','r']
        rows['f']=['d','g']
        rows['g']=['f','h']
        rows['h']=['g','j']
        rows['i']=['u','o']
        rows['j']=['h','k']
        rows['k']=['j','l']
        rows['l']=['k']
        rows['m']=['n']
        rows['n']=['b','n']
        rows['o']=['i','p']
        rows['p']=['o']
        rows['q']=['w']
        rows['r']=['e','t']
        rows['s']=['a','d']
        rows['t']=['r','y']
        rows['u']=['y','i']
        rows['v']=['c','b']
        rows['w']=['e','q']
        rows['x']=['c','z']
        rows['y']=['t','u']
        rows['z']=['x']


     cols['a']=['q','z','w']
     cols['b']=['g','h']
     cols['c']=['d','f']
     cols['d']=['e','r','c']
     cols['e']=['d']
     cols['f']=['r','v','c']
     cols['g']=['t','b','v']
     cols['h']=['y','b','n']
     cols['i']=['k']
     cols['j']=['u','m','n']
     cols['k']=['i','m']
     cols['l']=['o']
     cols['m']=['j','k']
     cols['n']=['h','j']
     cols['o']=['l']
     cols['p']=['l']
     cols['q']=['a']
     cols['r']=['f']
     cols['s']=['w','x','z']
     cols['t']=['g','f']
     cols['u']=['j']
     cols['v']=['f','g']
     cols['w']=['s']
     cols['x']=['s','d']
     cols['y']=['h']
     cols['z']=['a','s']

     rand_num = rand()

     if char_range == "alpha"
         # A randomly chosen neigbouring key in the same keyboard row
         if all(isalpha,input_char) && rand_num <= single_typo_prob["same_row"]
             output_char = rand(rows[input_char])
            # print("++++++:",output_char)
        # A randomly chosen neigbouring key in the same keyboard column
        elseif all(isalpha,input_char) && rand_num <= (single_typo_prob["same_row"] + single_typo_prob["same_col"])
            output_char = rand(cols[input_char])
            #print("#####:",output_char)
        else
            choice_str = replace(string_lowercase,input_char,"")
            output_char = rand(split(choice_str,""))
            #print("****:",output_char)
         end
     end
     return output_char
end

error_character('s',"alpha")

error_position("samudra",0)

function maincall()
    type_modification = "typo"
    field_names = Array{AbstractString,1}()
    prob_names = ["ins_prob","del_prob","sub_prob","trans_prob","val_swap_prob",
              "wrd_swap_prob","spc_ins_prob","spc_del_prob","miss_prob",
              "misspell_prob","new_val_prob"]
    select_prob_sum = 0.0
end

function introduce_typos(org_field_val::AbstractString, numbers_of_duplicates::Int64)

    dup_field_values = Array{AbstractString,1}()

    push!(dup_field_values,org_field_val)

    while length(dup_field_values) <= numbers_of_duplicates

        mod_op = rand(prob_names)
        #mod_op="spc_del_prob"
        dup_field_val = org_field_val

        if mod_op=="sub_prob"
        # Get an substitution position randomly
            rand_sub_pos = error_position(dup_field_val, 0)

            if (rand_sub_pos != nothing && rand_sub_pos!= 0)
                print("ok...: ", rand_sub_pos)
                old_char = dup_field_val[rand_sub_pos]
                new_char = error_character(old_char, "alpha")
                #print("new_char:", new_char)
                new_field_val = dup_field_val[1:rand_sub_pos-1] * string(new_char) * dup_field_val[rand_sub_pos+1:end]

                if (new_field_val != dup_field_val)
                    print("Substituted character $old_char with $new_char :  in $dup_field_val to $new_field_val")
                    dup_field_val = new_field_val
                end
            end

        elseif mod_op=="ins_prob"

            rand_ins_pos = error_position(dup_field_val, +1)
            rand_char = rand(split(string_lowercase,""))

            if (rand_ins_pos != nothing && rand_ins_pos!= 0)
                dup_field_val = dup_field_val[1:rand_ins_pos-1] * rand_char *  dup_field_val[rand_ins_pos:end]
                print("Inserted character $rand_char to $dup_field_val")
            end

    elseif mod_op=="del_prob" && dup_field_val != nothing && length(dup_field_val) > 1

             rand_del_pos = error_position(dup_field_val, 0)
             print("rand_del_pos:  $rand_del_pos")

             if (rand_del_pos != nothing && rand_del_pos!= 0)

                 del_char = dup_field_val[rand_del_pos]
                 dup_field_val = dup_field_val[1:rand_del_pos-1] * dup_field_val[rand_del_pos+1:end]
                 print("Deleted character $del_char to $dup_field_val")
            end

        elseif mod_op == "spc_ins_prob" && dup_field_val!= nothing && length(strip(dup_field_val)) > 1

             dup_field_val=strip(dup_field_val)
             rand_ins_pos = error_position(dup_field_val, 0)

             if rand_ins_pos!=0
                 if (dup_field_val[rand_ins_pos] == ' ') || (dup_field_val[rand_ins_pos+1] == ' ')
                     print("No space inserted")
                 else
                    # print("Inserted space ")
                     new_field_val = dup_field_val[1:rand_ins_pos-1] * " " * dup_field_val[rand_ins_pos:end]
                     if (new_field_val != dup_field_val)
                             dup_field_val = new_field_val
                             print("Inserted space  to $dup_field_val")
                     end
                 end
            end
         #while (dup_field_val[rand_ins_pos-1] == ' ') || (dup_field_val[rand_ins_pos] == ' ')
            # print("Inserted space ")
            #rand_ins_pos = error_position(dup_field_val, 0)
            #new_field_val = dup_field_val[1:rand_ins_pos-1] * " " * dup_field_val[rand_ins_pos:end]
            #if (new_field_val != dup_field_val)
            #        dup_field_val = new_field_val
            #        print("Inserted space  to $dup_field_val")
            #end
        #end

        elseif (mod_op == "spc_del_prob") && (dup_field_val != nothing) && contains(dup_field_val," ")

            print("Deleted the spaces")
             num_spaces = count(c->c==' ', collect(dup_field_val))

             if (num_spaces == 1)
                  # Get index of the space
                space_ind = find(x->x==' ', dup_field_val )
                new_field_val = dup_field_val[1:space_ind[1]-1] * dup_field_val[space_ind[1]+1:end]
             else
                new_field_val = replace(dup_field_val,' ',"")
             end
             if (new_field_val != dup_field_val)
                 dup_field_val = new_field_val
                 print("Deleted the spaces in $dup_field_val")
             end
        end

        if dup_field_val in dup_field_values
            # print("Value exists..")
        else
            push!(dup_field_values,dup_field_val)
        end
    end
    return dup_field_values
end

introduce_typos("james",50)
