//
// File:    cnd-tek-nic.scad
// Project: Dell Wyse 5070 2nd Ethernet Adapter Adapter
// Desc:    Mock-up of CND-TEK T-shaped M.2 NIC daughter board
//

include <smidge.scad>;

// CND-TEK T-shaped NIC daughter board
//
// PCB: 30mm wide x 20mm deep, T-shaped
//   - Front (wide) section: 30mm x 9mm
//   - Rear (narrow) section: 21mm x 11mm
//   - Cutouts: 4.5mm wide x 11mm deep on each side at rear
//
// Ethernet jack: ~16x16x11mm, centered, protrudes ~2mm past front edge
// Mounting holes: ~4.5mm from front, ~3mm from sides, ~3mm diameter
// PCB thickness: ~1.0mm
// No shield used
//

function nic_kind() = "cnd-tek";

// PCB bounding box (full extent)
function nic_get_pcb_size() = [ 30, 20, 1.0 ];

// T-shape cutout dimensions
_cutout_width = 4.5;
_cutout_depth = 11;
_front_section_depth = nic_get_pcb_size().y - _cutout_depth; // 9mm
_narrow_width = nic_get_pcb_size().x - 2*_cutout_width; // 21mm

// ethernet size [left<->right, front<->rear, top<->bottom]
function nic_get_ethernet_size() = [16, 16, 11];

// shield: not used but needed for interface compatibility
function nic_get_shield_thickness() = 0;
function nic_get_shield_size() = [ 0, 0, 0 ];
function nic_get_shield_holes() = [];
function nic_get_shield_hole_diameter() = 0;
function nic_get_shield_z() = 0;
function nic_get_shield_center_pos() = [ 0, 0 ];

// ethernet position - centered on 30mm width
function _nic_get_ethernet_left_pos() = (nic_get_pcb_size().x - nic_get_ethernet_size().x)/2;
function _nic_get_ethernet_right_pos() = (nic_get_pcb_size().x + nic_get_ethernet_size().x)/2;
function _nic_get_ethernet_bottom_pos() = nic_get_pcb_size().z + 0.0;
function nic_get_ethernet_center_pos() = [ (_nic_get_ethernet_left_pos()+_nic_get_ethernet_right_pos())/2, _nic_get_ethernet_bottom_pos() + nic_get_ethernet_size().z/2 ];
function nic_get_ethernet_projection() = 2.0;

// bottom hole positions [left=0, rear=0]
// ~3mm from sides, ~4.5mm from front => Y = pcb_depth - 4.5
function _nic_get_left_hole() = [ 3.0, nic_get_pcb_size().y - 4.5 ];
function _nic_get_right_hole() = [ nic_get_pcb_size().x - 3.0, nic_get_pcb_size().y - 4.5 ];
function nic_get_bottom_holes() = [ _nic_get_left_hole(), _nic_get_right_hole() ];
function nic_get_bottom_hole_diameter() = 3.0;

// Layout of the nic board
module nic(transparency=1.0, center=true, with_shield=true) {

  module hole(height, diameter) {
    translate( [0,0,-SMIDGE] ) cylinder( h = height+2*SMIDGE, d=diameter );
  }

  // T-shaped PCB
  module pcb() {
    color( "green", transparency ) {
      // Front wide section: full 30mm width, 9mm deep
      translate( [0, nic_get_pcb_size().y - _front_section_depth, 0] )
        cube( [nic_get_pcb_size().x, _front_section_depth, nic_get_pcb_size().z] );
      // Rear narrow section: 21mm centered, 11mm deep
      translate( [_cutout_width, 0, 0] )
        cube( [_narrow_width, _cutout_depth, nic_get_pcb_size().z] );
    }
  }

  // Ethernet jack
  module ethernet() {
    color( "silver", transparency )
      translate( [_nic_get_ethernet_left_pos(), nic_get_pcb_size().y - nic_get_ethernet_size().y + nic_get_ethernet_projection(), _nic_get_ethernet_bottom_pos()] )
        cube( nic_get_ethernet_size() );
  }

  translate( center ? -[nic_get_pcb_size().x, nic_get_pcb_size().y, 0]/2 : [0,0,0] ) {
    difference() {
      union() {
        pcb();
        ethernet();
      }

      // Bottom holes
      for( h = nic_get_bottom_holes() )
        translate( concat( h, -1 ) ) hole( nic_get_pcb_size().z + 2, nic_get_bottom_hole_diameter() );
    }
  }
}

nic($fn=24);
