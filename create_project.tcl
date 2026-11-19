set root [file dirname [file normalize [info script]]]
set variant zybo
if {$argc > 0} { set variant [lindex $argv 0] }
switch -- $variant {
    zybo { set part xc7z010clg400-1; set pins zybo.xdc }
    z7-10 { set part xc7z010clg400-1; set pins zybo_z7.xdc }
    z7-20 { set part xc7z020clg400-1; set pins zybo_z7.xdc }
    default { error "Use zybo, z7-10, or z7-20" }
}
create_project zybo_test [file join $root build $variant] -part $part -force
add_files [file join $root zybo_test.v]
add_files -fileset constrs_1 [list [file join $root common.xdc] [file join $root $pins]]
add_files -fileset sim_1 [file join $root tb_zybo_test.v]
set_property top zybo_test [get_filesets sources_1]
set_property top tb_zybo_test [get_filesets sim_1]
update_compile_order -fileset sources_1
