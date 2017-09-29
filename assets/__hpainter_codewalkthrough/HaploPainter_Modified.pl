###########################################################################

### default values global and famliy specific
my $def = {
	GLOB => {
		BACKGROUND => '#ffffff', 
		BORDER => 20,
		CURSOR => 'left_ptr',
		DB_TYPE => '',
		DB_PORT => '',
		DB_SID => '',
		DB_HOST => '',
		DB_UNAME => '',
		DB_PASSWD => '',
		DB_RELATION => '',
		ORIENTATION 	=> 'Landscape',
		PAPER	=> 'A4',						
		RESOLUTION_DPI  => 96,
		STATUS => 0,
		STRUK_MODE => 0,
		VERSION	=> '1.043'
	},
	FAM => {
		ADOPTED_SPACE1 => 5,
		ADOPTED_SPACE2 => 3,
		AFF_COLOR => {
			0 => '#c0c0c0',
			1 => '#ffffff',
			2 => '#000000',
			3 => '#ff7f50',
			4 => '#ffd700',
			5 => '#6b8e23',
			6 => '#1e90ff',
			7 => '#ba55d3',
			8 => '#adff2f',
			9 => '#cd5c5c',
		},
		ALIGN_LEGEND => 1,
		ALIVE_SPACE => 5,
		ALLELES_SHIFT => 15,
		ARROW_COLOR => '#000000',
		ARROW_DIST1 => 7,
		ARROW_DIST2 => 9,
		ARROW_DIST3 => 4,
		ARROW_LENGTH => 13,
		ARROW_LINE_WIDTH => 1.5,		
		ARROW_SYM_DIST => 5,		
		BBOX_WIDTH => 35,
		BREAK_LOOP_OK => {},
		CASE_INFO_SHOW => { 1 => 1, 2 => 0, 3 => 0, 4 => 0, 5 => 0 },
		CONSANG_DIST => 4,
		COUPLE_REL_DIST => 0.15,
		CROSS_FAKTOR1 => 1,
		EXPORT_BACKGROUND => 0,
		FILL_HAPLO => 1,
		FONT1 => {
			COLOR => '#000000',
			FAMILY => 'Arial',
			SIZE => 16,
			SLANT => 'roman',
			WEIGHT => 'bold'
		},
		FONT_HAPLO => {
			COLOR => '#000000',
			FAMILY => 'Arial',
			SIZE => 14,
			SLANT => 'roman',
			WEIGHT => 'bold'
		},
		FONT_HEAD => {
			COLOR => '#000000',
			FAMILY => 'Arial',      
			SIZE => 30,
			SLANT => 'roman',
			WEIGHT => 'bold'
		},
		FONT_INNER_SYMBOL => {
			COLOR => '#000000',
			FAMILY => 'Arial',
			SIZE => 16,
			SLANT => 'roman',
			WEIGHT => 'bold'
		},
		FONT_PROBAND => {
			COLOR => '#000000',
			FAMILY => 'Arial',
			SIZE => 12,
			SLANT => 'roman',
			WEIGHT => 'bold'
		},
		FONT_MARK => {
			COLOR => '#000000',
			FAMILY => 'Arial',
			SIZE => 12,
			SLANT => 'roman',
			WEIGHT => 'bold'
		},
		GITTER_X => 25,
		GITTER_Y => 25,
		HAPLO => {},
		HAPLO_LW => 1,
		HAPLO_SEP_BL => 0,
		HAPLO_SPACE => 9,
		HAPLO_TEXT_LW => 0,
		HAPLO_UNKNOWN => 0,
		HAPLO_UNKNOWN_COLOR => '#000000',
		HAPLO_WIDTH => 12,
		HAPLO_WIDTH_NI => 4,
		LEGEND_SHIFT_LEFT => 200,
		LEGEND_SHIFT_RIGHT => 50,
		LINE_COLOR => '#000000',
		LINE_WIDTH => 1,
		LINE_SIBS_Y => 40,
		LINE_CROSS_Y => 15,
		LINE_TWINS_Y => 35,
		LOOP_BREAK_STATUS => 0,
		MARKER_POS_SHIFT => 155,
		PED_ORG => {},
		PROBAND_SIGN => 'P',
		SHOW_COLORED_TEXT => 0,
		SHOW_GENDER_SAB => 1,
		SHOW_HAPLO_BAR => 1,
		SHOW_HAPLO_BBOX => 1,
		SHOW_HAPLO_NI_0 => 1,
		SHOW_HAPLO_NI_1 => 1,
		SHOW_HAPLO_NI_2 => 1,
		SHOW_HAPLO_NI_3 => 0,
		SHOW_HAPLO_TEXT => 1,
		SHOW_HEAD => 1,
		SHOW_LEGEND_LEFT => 1,
		SHOW_LEGEND_RIGHT => 0,
		SHOW_MARKER => 1,
		SHOW_POSITION => 1,
		SHOW_INNER_SYBOL_TEXT => 1,
		SYMBOL_LINE_COLOR => '#0000ff',
		SYMBOL_LINE_WIDTH => 2,
		SYMBOL_SIZE => 25,
		SYMBOL_LINE_COLOR_SET => 0,
		X_SPACE => 3,
		Y_SPACE => 6,
		Y_SPACE_DEFAULT => 6,
		Y_SPACE_EXTRA => 15,
		ZOOM => 1
	}
};




#==============
sub DeleteSID {
#==============
	my $fam = $self->{GLOB}{CURR_FAM} or return;
	my @act_sym = keys % { $self->{GLOB}{ACTIVE_SYMBOLS} } or return;
	my $flag;
	foreach my $sym (@act_sym) {
		(my $p) = $sym =~ /^SYM-(.+)$/ or next;
		my $p_old = $self->{FAM}{CASE_INFO}{$fam}{PID}{$p}{Case_Info_1} or next;
		
		foreach my $r (@ { $self->{FAM}{PED_ORG}{$fam} }) {
			if ($r && $r->[0] eq $p_old) {
				$flag = 1;undef $r;
				
				### mark children as founder
				foreach my $child_id (keys % { $self->{FAM}{CHILDREN}{$fam}{$p} }) {						
					my $child_old = $self->{FAM}{CASE_INFO}{$fam}{PID}{$child_id}{Case_Info_1} or next;
					L2:foreach my $r2 (@ { $self->{FAM}{PED_ORG}{$fam} }) {
						if ($r2 && $r2->[0] eq $child_old) {
							$r2->[1] = 0;$r2->[2] = 0;last L2
						}
					}					
				}							
			}
		}						
	}
	
	if ($flag) {		
		### remove zombie PIDs
		my %z;
		my $c=0;
		my $c2=0;
		foreach my $r (@ { $self->{FAM}{PED_ORG}{$fam} }) {
			next unless $r;
			$z{P}{$r->[0]} = 1;
			$z{R}{$r->[1]}++ if $r->[1];
			$z{R}{$r->[2]}++ if $r->[2];
		}
		foreach my $p (keys % { $z{P} }) {
			my $sid = $self->{FAM}{PID2PIDNEW}{$fam}{$p};
			if (! $z{R}{$p} && $self->{FAM}{FOUNDER}{$fam}{$sid}) {
				foreach my $r (@ { $self->{FAM}{PED_ORG}{$fam} }) {
					if ($r && $r->[0] eq $p) { undef $r }
				}	
			}
		}
		### count individuals and left non-founder
		foreach my $r (@ { $self->{FAM}{PED_ORG}{$fam} }) {
			next unless $r;
			$c++; 
			$c2++ if $r->[1];
		}	
		### remove family if individuals are lower then 3 or all left are non-founder
		if ( ($c<3) || !$c2 ) { Clear('curr') }
		else { RedrawPedForce() }
	}
}



# MakeSelfGlobal is called once to copy the defaults into $self
# It holds object orientated all subvariables in one hash. 
# The structure is saved later by Storable.pm
#===================
sub MakeSelfGlobal {
#===================
	## copy up to three hash levels from $def to $self
	foreach my $k1 (keys % { $def->{GLOB} }) {
		if (ref $def->{GLOB}{$k1}) { 
			foreach my $k2 (keys % { $def->{GLOB}{$k1} }) {
				if (ref $def->{GLOB}{$k1}{$k2}) { 
					foreach my $k3 (keys % { $def->{GLOB}{$k1}{$k2} }) {					
						$self->{GLOB}{$k1}{$k2}{$k3} = $def->{GLOB}{$k1}{$k2}{$k3}
					}
				}
				else { $self->{GLOB}{$k1}{$k2} = $def->{GLOB}{$k1}{$k2} }	
			}			
		}
		else { $self->{GLOB}{$k1} = $def->{GLOB}{$k1} }	
	} 
}

### copy defaults for given family
#=================
sub AddFamToSelf {
#=================
	my $fam = shift @_ || $self->{GLOB}{CURR_FAM};
	unless ($fam) { ShowInfo("Achtung : Argumentfehler in Funktion AddFammToSelf ", 'error'); return }
	## copy up to three hash levels from $def to $self
	foreach my $k1 (keys % { $def->{FAM} }) {
		if (ref $def->{FAM}{$k1}) { 
			foreach my $k2 (keys % { $def->{FAM}{$k1} }) {
				if (ref $def->{FAM}{$k1}{$k2}) { 
					foreach my $k3 (keys % { $def->{FAM}{$k1}{$k2} }) {					
						$self->{FAM}{$k1}{$fam}{$k2}{$k3} = $def->{FAM}{$k1}{$k2}{$k3}
					}
				}
				else { $self->{FAM}{$k1}{$fam}{$k2} = $def->{FAM}{$k1}{$k2} }	
			}			
		}
		else { $self->{FAM}{$k1}{$fam} = $def->{FAM}{$k1} }	
	} 
}





# Start drawing one pedigree
#=========
sub DoIt {
#=========					
	LoopBreak();
	FindTop() or return;	
	BuildStruk();
	DuplicateHaplotypes();
	ShuffleFounderColors();
	ProcessHaplotypes();				
	DrawPed();
	DrawOrExportCanvas();
	AdjustView(-fit => 'center');	
	1;
}

#==============
sub RedrawPed {
#==============	
	SetSymbols();	
	SetLines();	
	SetHaplo();	
	DrawOrExportCanvas() if !$batch;		
}

#===================
sub RedrawPedForce {
#===================
	my $fam = $self->{GLOB}{CURR_FAM} or return;
	foreach my $k ( keys % { $self->{FAM} } ) {
		next if $k eq 'MAP';
		next if $k eq 'TITLE';
		undef $self->{FAM}{$k}{$fam} if ! defined $def->{FAM}{$k};
	}
	undef $self->{GLOB}{ACTIVE_SYMBOLS};
	ProcessFamily($fam) or return;
	FindLoops($fam);
	DoIt($fam);
}

#=================
sub DrawOrRedraw {
#=================
	my $fam = shift @_ or return undef;
	$self->{GLOB}{CURR_FAM} = $fam;
	undef $self->{GLOB}{ACTIVE_SYMBOLS};
	if (! $self->{FAM}{MATRIX}{$fam}) { DoIt() }
	else { RedrawPed() }	
}

#=======================
sub StoreDrawPositions {
#=======================
	my $fam = $self->{GLOB}{CURR_FAM} or return;
	
	### Store canvas and scrollbar positions
	$self->{FAM}{CANVAS_SCROLLREGION}{$fam} = [ $canvas->Subwidget('canvas')->cget(-scrollregion) ];
	$self->{FAM}{CANVAS_XVIEW}{$fam} = [ $canvas->xview ];
	$self->{FAM}{CANVAS_YVIEW}{$fam} = [ $canvas->yview ];

}

#=========================
sub RestoreDrawPositions {
#=========================
	my $fam = $self->{GLOB}{CURR_FAM} or return;
	return unless $self->{FAM}{CANVAS_SCROLLREGION}{$fam};
	
	### Restore canvas and scrollbar positions
	$canvas->configure(-scrollregion => $self->{FAM}{CANVAS_SCROLLREGION}{$fam});
	$canvas->xviewMoveto($self->{FAM}{CANVAS_XVIEW}{$fam}[0]);
	$canvas->yviewMoveto($self->{FAM}{CANVAS_YVIEW}{$fam}[0]);

}

#=============
sub ShowInfo {
#=============	
	my ($info, $type) = @_;
	if ($batch) { print "$info\n" }
	else {
		$mw->messageBox(
			-title => 'Status report', -message => $info,
			-type => 'OK', -icon => $type || 'info'
		)
	}
}


# This method implements maximal number of trials to find good drawing solutions
# Given values are found empirical working well. The alligning algorhithm still could be improved !
#============
sub DrawPed {
#============
	my $fam = shift @_ || $self->{GLOB}{CURR_FAM};
	my $CrossMin = 0;
	my ($save, $flag);
	my $cursor = $self->{GLOB}{CURSOR};
		
	if (! $batch) {
		$self->{GLOB}{CURSOR} = 'watch';
		$canvas->configure(-cursor => $self->{GLOB}{CURSOR});
		$canvas->update();
	}
	WHILE:while (1) {
		$flag = 0;
		my $n = 35; if ($param->{SORT_BY_PEDID}) { $n=1 }
		FOR:for my $n ( 1 .. $n ) {		
						
			BuildMatrix($fam);				
			my $count = 0; until (AlignMatrix($fam)) { $count++ ; last if $count > $param->{MAX_COUNT} }											
			SetLines($fam);
			my $c = CountLineCross($fam);
			unless ($c) {					
				SetSymbols($fam);				
				SetHaplo($fam);
				last WHILE
			}
			
			if (! $batch) {
				my $text = sprintf("%9s%18s%20s  ","Try #$n", "Crosses #$c", "min crosses #$CrossMin");
				$param->{INFO_LABEL}->configure(-text => $text);
				$mw->update();
			}
			
			$CrossMin = $c unless $CrossMin;
		
			if ($c < $CrossMin) {
				$CrossMin = $c;
				$save = freeze($self);
				$flag = 1;
				last FOR;
			}
			else {			
				FindTop($fam);
				BuildStruk($fam);							
			}
		}
		
		unless ($flag) {
			$self = thaw($save) if $save;
			SetSymbols($fam);		
			SetHaplo($fam);
			last WHILE;
		}
	}
	if (!$batch) {
		$self->{GLOB}{CURSOR} = $cursor;
		$canvas->configure(-cursor => $self->{GLOB}{CURSOR});
		$canvas->update();
	}
	
	1;
}

# $self will be stored by Storable ...
#=============
sub SaveSelf {
#=============	
	return unless $self->{GLOB}{CURR_FAM};
	if ($_[0] || !$self->{GLOB}{FILENAME_SAVE}) {
		$_ = $mw->getSaveFile(
			-initialfile 	=> basename($self->{GLOB}{FILENAME}),
			-defaultextension	=> 'hp', -filetypes		=> [ [ 'All Files',	 '*' ], [ 'HaploPainter Files', 'hp' ] ]
		) or return undef;
		$self->{GLOB}{FILENAME} = $_;
		$self->{GLOB}{FILENAME_SAVE} = 1;
	} else {
		$_ = $self->{GLOB}{FILENAME} or return undef
	}
	$canvas->configure(-cursor => 'watch');
	store $self, $_;
	$canvas->configure(-cursor => $self->{GLOB}{CURSOR});
}

#====================
sub RestoreSelfGUI {
#====================
	my $file = $mw->getOpenFile() or return undef;
	RestoreSelf($file,1);
	$self->{GLOB}{FILENAME} = $file;
	$self->{GLOB}{FILENAME_SAVE} = 1;
}

# ... and restored ...
#================
sub RestoreSelf {
#================	
	my ($file, $flag) = @_ or return undef;
	my $test; eval { $test = retrieve($file) };
	if ($@ && $flag) { ShowInfo "File reading error!\n$@", 'warning'; return undef}
	if ($@ && ! $flag) { return undef }
	
	### check for compatability --> old Versions do not have this variable
	### if changes in save format break backward compatibility --> do it here
	if ( ! $test->{GLOB}{VERSION} ) {
		ShowInfo "This version of HaploPainter does not support the specified file format!", 'warning'; return 
	}
	
	$self =$test;
	$canvas->update();
	$canvas->configure(-background  => $self->{GLOB}{BACKGROUND});

	my $fileref = $menubar->entrycget('View', -menu);
	my $drawref = $fileref->entrycget('Draw Pedigree ...', -menu);
	$drawref->delete(0,'end');
	
	for my $fam (nsort keys % { $self->{FAM}{PED_ORG} }) { 
		$drawref->add('command', -label => $fam, -command => sub {DrawOrRedraw($fam)} ) 
	}
	
	RedrawPed();
	AdjustView(-fit => 'center');
	1;
}

###  Loops there? If yes store information for later queries
#==============
sub FindLoops {
#==============	
	my $fam = shift @_ || $self->{GLOB}{CURR_FAM};
	my $s = $self->{FAM}{LOOP}{$fam} = {};
	my (%path, $flag, %P, %N, %D, %D1, %D2, %K, %L, %B);
	my $node_cc = 1;
	
	### network for loop detection
	### couples as nodes
	foreach my $node ( keys % { $self->{FAM}{PARENT_NODE}{$fam} }) {
		my ($fid, $mid) = @ { $self->{FAM}{PARENT_NODE}{$fam}{$node} };
		
		### check for parent nodes
		foreach my $parent ($fid, $mid) {
			if ( defined $self->{FAM}{SID2FATHER}{$fam}{$parent} && defined $self->{FAM}{SID2MOTHER}{$fam}{$parent} ) {
				my ($fpar, $mpar) = ($self->{FAM}{SID2FATHER}{$fam}{$parent}, $self->{FAM}{SID2MOTHER}{$fam}{$parent});
				my $parnode = join '==', nsort($fpar, $mpar);
				$N{$node}{$parnode} = 1;
			}
		}
		
		### check for child nodes
		foreach my $child ( keys % { $self->{FAM}{CHILDREN_COUPLE}{$fam}{$fid}{$mid} }) {
			if (defined $self->{FAM}{CHILDREN_COUPLE}{$fam}{$child}) {
				foreach my $mate (keys % { $self->{FAM}{CHILDREN_COUPLE}{$fam}{$child} }) {
					my $parnode = join '==', nsort($child, $mate);
					$N{$node}{$parnode} = 1;
				}
			}	
		}
		
		### create joining parent node for multiple mates without shared parents
		foreach my $parent ( keys % { $self->{FAM}{CHILDREN_COUPLE}{$fam} } ) {			
			### is this a multiple mate situation?
			if (scalar (keys % { $self->{FAM}{CHILDREN_COUPLE}{$fam}{$parent} }) > 1) {				
				### there is no parent node for this set of multiple mate child nodes
				if (! defined $self->{FAM}{SID2FATHER}{$fam}{$parent} && ! defined $self->{FAM}{SID2MOTHER}{$fam}{$parent} ) {					
					### pseudo node creation to connect joined mates by one parent node
					my @mates = nsort keys % { $self->{FAM}{CHILDREN_COUPLE}{$fam}{$parent} };
					my $node = 'PSNODE_' . join ('==', (@mates, $parent)) . '_PSNODE';
					
					foreach my $mate (@mates) {
						my $parnode = join '==', nsort($parent, $mate);
						$N{$node}{$parnode} = 1;
						$N{$parnode}{$node} = 1;
					}
				}
			}
		}
	}
		
	### prepare start tree including root and one further level
	foreach my $node1 (keys %N) {		
		foreach my $node2 (keys % { $N{$node1} }) {
			$path{$node_cc} = [ $node1, $node2 ]; $node_cc++;
		}
	}
	#print Dumper(\%path);
	### This code evaluates all loops, clock/anticlock 
	### at every start position inside the loop
	W:while (!$flag) {
		$flag = 1;
		foreach my $p (keys %path) {
			my $r = $path{$p};
			my @plist = @$r;			
			next if $r->[-1] eq 'LOOP';
			
			### delete this path and substitute it by child pathes next in code
			### If there is no path to subsitute it is removed by the way											
			delete $path{$p};
			
			### spacial case inter sibling mate 
			my ($pid1, $pid2) = split '==', $r->[-1];					
			### both sibling and halfsibling mates (may be better handle as separate cases)
			if (defined $self->{FAM}{SID2FATHER}{$fam}{$pid1} && defined $self->{FAM}{SID2FATHER}{$fam}{$pid2} &&
				defined $self->{FAM}{SID2MOTHER}{$fam}{$pid1} && defined $self->{FAM}{SID2MOTHER}{$fam}{$pid2}) {
				if (($self->{FAM}{SID2FATHER}{$fam}{$pid1} eq $self->{FAM}{SID2FATHER}{$fam}{$pid2}) or 
					($self->{FAM}{SID2MOTHER}{$fam}{$pid1} eq $self->{FAM}{SID2MOTHER}{$fam}{$pid2})) {
					#$path{$node_cc} = [ @plist, 'LOOP' ];  $node_cc++; next W	
					$s->{CONSANGUINE}{$pid1}{$pid2} = 1;
					$s->{CONSANGUINE}{$pid2}{$pid1} = 1;
					$_ = join '==', nsort($pid1,$pid2);
					$s->{CONSANGUINE_ORG}{$_} = 1;					
				}
			}
			
			### there is only one way back --> delete this path
			my @subnodes = keys % { $N{ $r->[-1] } };
			next if scalar @subnodes == 1;
			
			### look for subnodes
			F:foreach my $node (@subnodes) {
				### dont go back inside the path!
				next if $node eq $plist[-2];
				### unperfect LOOP --> no further processing
				for ( 1 .. scalar @plist-1 ) { next F if $plist[$_] eq $node }
				### perfect LOOP ( start = end)
				if ($node eq $plist[0]) { $path{$node_cc} = [ @plist, 'LOOP' ];  $node_cc++  }		
				### expand paths by subnodes else				
				else { 										
					$path{$node_cc} = [ @plist, $node ]; $node_cc++; undef $flag 
				}
			}
		}		
	}	
	
	### processing paths to find duplicates
	foreach my $node (keys %path) {		
		@_ = ();
		foreach (@ {$path{$node}}) {
			### remove LOOP-end tag and pseudonodes
			next if /LOOP|PSNODE/;
			push @_, $_;
		}
		$_ = join '___', nsort(@_);
		$D{$_} = [ @_ ];
		foreach my $e (@_) { $D1{$_}{$e} = 1 }
	}
	
	### return if no loops there
	return unless keys %D;
	
	## if a small loop is part of a bigger loop store this information	
	foreach my $loop1 (keys %D1) {
		foreach my $loop2 (keys %D1) {
			next if $loop1 eq $loop2;
			my ($lp1, $lp2);
			if (  (scalar keys % { $D1{$loop1} }) <  (scalar keys % { $D1{$loop2} }) ) {
				($lp1, $lp2) = ($loop1, $loop2);
			}
			elsif (  (scalar keys % { $D1{$loop1} }) >  (scalar keys % { $D1{$loop2} }) ) {
				($lp1, $lp2) = ($loop2, $loop1);
			}			
			if ($lp1) {
				my $flag;
				foreach my $k (keys % { $D1{$lp1} }) { $flag = 1 if ! $D1{$lp2}{$k} }													
				$D2{$lp2} = 1 if ! $flag								
			}
		}
	}
	
	### analyse loop structure
	### find start, middle and end nodes/individuals
	### start nodes/individuals have no parent node but children nodes
	### middle nodes have start and end nodes
	### end nodes have no children but parent nodes	
	my $countl = 0;	
	foreach my $loop (keys %D) {
		my %start_nodes;
		$countl++;
		my @loop_list = @ {$D{$loop}};
		#print Dumper(\@loop_list);
		my %E;
		### build Hash for every individual inside the loop 
		foreach my $couple (@loop_list) {
			foreach my $pid (split '==', $couple) {
				$E{$pid} = 1;
			}
		}
		
		### exploring loop
		my @node_types;
		foreach my $node (@loop_list) {
			my ($p1, $p2) = (split '==', $node);
			
			### there is a chance that this is a multiple mate case and
			### one of that mate is further connected
			
			### getting all connected mates of this node which are part of the loop
			my %P = ( $p1, 1, $p2, 1);			
			W:while (1) {
				undef $flag;
				foreach my $p ( keys %P ) {
					foreach my $c ( keys % { $self->{FAM}{COUPLE}{$fam}{$p} }) {
						if (! $P{$c} && $E{$c}) { $P{$c} = 1; $flag = 1 }
					}
				}
				last W unless $flag
			}
			
			my ($no_start_flag, $no_end_flag) = (0,0);
			foreach my $p (keys %P) {
				### this cannot be a start node
				if ($self->{FAM}{SID2FATHER}{$fam}{$p} && $E{$self->{FAM}{SID2FATHER}{$fam}{$p}})  { $no_start_flag = 1 }
				if ($self->{FAM}{SID2MOTHER}{$fam}{$p} && $E{$self->{FAM}{SID2MOTHER}{$fam}{$p}})  { $no_start_flag = 1 }
				
				### this cannot be a end node
				foreach my $p1 (keys %P) {
					foreach my $p2 (keys %P) {
						if ($self->{FAM}{CHILDREN_COUPLE}{$fam}{$p1}{$p2}) {
							foreach my $child (keys %{$self->{FAM}{CHILDREN_COUPLE}{$fam}{$p1}{$p2}}) {
								if ($E{$child}) { $no_end_flag = 1 }
							}
						}
					}
				}
			}
						
			### START nodes
			if (! $no_start_flag && $no_end_flag) {
				$s->{START}{$p1}{$p2} = 1;
				$s->{START}{$p2}{$p1} = 1;
				$s->{NR2START}{$countl}{$p1} = 1;
				$s->{NR2START}{$countl}{$p2} = 1;
				if ( (scalar keys %P) > 2 ) { 
					push @node_types, 'SM';
				}
				else { push @node_types, 'S_' }
			}
			
			### END nodes
			elsif ( $no_start_flag && ! $no_end_flag) {
				$s->{END}{$p1}{$p2} = 1;
				$s->{END}{$p2}{$p1} = 1;				
				$s->{NR2END}{$countl}{$p1} = 1;
				$s->{NR2END}{$countl}{$p2} = 1;
				
				if ( (scalar keys %P) > 2 ) { 
					push @node_types, 'EM';
				}
				else {
					if ($self->{FAM}{COUPLE}{$fam}{$p1} && $self->{FAM}{COUPLE}{$fam}{$p1}{$p2}) {
						$s->{CONSANGUINE}{$p1}{$p2} = 1;
						$s->{CONSANGUINE}{$p2}{$p1} = 1;
						$_ = join '==', nsort($p1,$p2);
						$s->{CONSANGUINE_ORG}{$_} = 1;
					}
					push @node_types, 'E_' 
				}			
			}
			
			### MIDDLE nodes
			elsif ( $no_start_flag && $no_end_flag) {
				$s->{MIDDLE}{$p1}{$p2} = 1;
				$s->{MIDDLE}{$p2}{$p1} = 1;				
				$s->{NR2MIDDLE}{$countl}{$p1} = 1;
				$s->{NR2MIDDLE}{$countl}{$p2} = 1;
				if ( (scalar keys %P) > 2 ) { 
					push @node_types, 'MM';
				}
				else { push @node_types, 'M_' }	
			}
		}
				
		### this is a hard to draw loop (found no end nodes in it)  --> mark proper nodes as consanguine
		if (! defined $s->{NR2END}{$countl}) {
			my %R;
			foreach my $node (@loop_list) {
				foreach my $p (split '==', $node) {
					if ($R{$p}) {
						foreach my $mate (keys % { $self->{FAM}{COUPLE}{$fam}{$p} }) {
							if ($E{$mate}) {							
								if ($self->{FAM}{SID2MOTHER}{$fam}{$mate} && $E{$self->{FAM}{SID2MOTHER}{$fam}{$mate}} && $self->{FAM}{SID2FATHER}{$fam}{$mate} && $E{$self->{FAM}{SID2FATHER}{$fam}{$mate}}) {										
									if ($self->{FAM}{COUPLE}{$fam}{$p} && $self->{FAM}{COUPLE}{$fam}{$p}{$mate}) {									
										$s->{CONSANGUINE}{$p}{$mate} = 1;
										$s->{CONSANGUINE}{$mate}{$p} = 1;
										$_ = join '==', nsort($p,$mate);
										$s->{CONSANGUINE_ORG}{$_} = 1;
									}	
								}
							}
						}
					}
					$R{$p}++;
				}				
			}
			
			### store those nodes including individuals occuring more then one time in all nodes from the loop
			### such individuals are candidates for breaking a loop
			foreach my $p1 (keys %R) {
				if ($R{$p1}>1) {
					foreach my $node (@loop_list) {
						foreach my $p2 (split '==', $node) {
							if ($p1 eq $p2) {
								$B{PID}{$p1}{$node} = 1;		
							}
						}
					}
				}
			}
		}

		### detection of "asymetric" loops
		### When loops are not in balance - that means that there are more middle nodes on the one side
		### then the other, the end note person which belongs to the side with lower middle notes 
		### must be prevented to draw in the middle part.		
		### It also has to be explored, if middle nodes belong to a multiple mate group (they count as one node together)				
		
		### loop twice over loop_list 
		### exploring number of middle nodes from START --> END
		my $cll = scalar @loop_list;
		my $cc1 = 0;
		my $i1;
		undef $flag;
		for my $i ( -$cll .. $cll-1 ) {
			if ($node_types[$i] =~ /S./) { $flag = 1; next }
			next unless $flag;      
			
			if ($node_types[$i] =~ /E./) {
				$i1 = $i;
				last
			}
			if ( (($node_types[$i] =~ /MM/) && ($node_types[$i-1] !~ /MM/)) or  ($node_types[$i] =~ /M_/)) {
				$cc1++; 
			}
		}
		
		### loop twice over loop_list 
		### exploring number of middle nodes from END --> START
		my $cc2 = 0;
		my $i2;
		undef $flag;
		for my $i ( -$cll .. $cll-1 ) {
			if ($node_types[$i] =~ /E./) { $flag = 1; next }
			next unless $flag;      
			if ($node_types[$i] =~ /S./) {
				$i2 = $i;
				last
			}	

			if ( (($node_types[$i] =~ /MM/) && ($node_types[$i-1] !~ /MM/)) or  ($node_types[$i] =~ /M_/)) {
				$cc2++;
			}
		}
		
		##### asymetric loop !!!
		if ( ($cc1 != $cc2) &&  ! $D2{$loop} ) {
			my ($n1, $n2);
			for my $i ( 1-$cll .. $cll-1 ) {			
				if ( 	($cc1 < $cc2) && ($node_types[$i] =~ /E./) && ($node_types[$i-1] =~ /M.|S./) ) {
					($n1, $n2) = @loop_list[$i-1, $i];
				}
				elsif ( ($cc1 > $cc2) && ($node_types[$i] =~ /M.|S./) && ($node_types[$i-1] =~ /E./) ) {
					($n1, $n2) = @loop_list[$i, $i-1];
				}
				
			}
			
			# very hard loop -> take a try		
			if (! $n1) {
				if ($node_types[0] =~ /S./) { ($n1, $n2) = @loop_list[0, -1] }
				else { ($n1, $n2) = @loop_list[-1, 0] }
			}
						
			my ($p1, $p2) = split '==', $n1;
			my ($p3, $p4) = split '==', $n2;
						
			if ( defined $self->{FAM}{CHILDREN_COUPLE}{$fam}{$p1}{$p2}{$p3} ) {
					$s->{DROP_CHILDREN_FROM}{$p3} = 1
			} 
			if ( defined $self->{FAM}{CHILDREN_COUPLE}{$fam}{$p1}{$p2}{$p4} ) {
				$s->{DROP_CHILDREN_FROM}{$p4} = 1
			}
		}
	}
	
	### some nodes could be common part of multiple loops
	### such nodes should be get off from individual duplication to prevent trouble
	foreach my $p ( keys % { $B{PID} } ) {
		foreach my $node ( keys % { $B{PID}{$p} } ) {
			$B{NODE}{$node}++;		
		}
	}

	#### mark indviduals for loop breaking in case of hard core loops
	if (keys %B) {
		foreach my $p ( keys % { $B{PID} } ) {
			my (@nodes, $flag);
			foreach my $node (keys % { $B{PID}{$p} }) {
				if ($B{NODE}{$node} == 1) { push @nodes, $node }
				else {$flag = 1}
			}
			ChangeOrder(\@nodes);
			shift @nodes if ! $flag;
			
			foreach (@nodes) {	
				my ($p1, $p2) = split '==', $_;
				if ($p eq $p1) {$s->{BREAK}{$p}{$p2} = 1} 
				else { $s->{BREAK}{$p}{$p1} = 1 }
			}						
		}
	}
	
	$s->{LOOP_COUNT} = $countl;
		
	### skip loops that end on same node
	### make new data structur for this task
	my %dupl;
	foreach my $loop (keys % { $s->{NR2END} }) {
		@_ = nsort keys % { $s->{NR2END}{$loop} };
		$_ = join '==', @_;
		$dupl{$_} = [ $loop , @_ ];		
	}	
	foreach my $k (keys %dupl) {
		my $nr = shift @ { $dupl{$k} };
		foreach ( @ { $dupl{$k} }) {
			$s->{NR2END_UNIQUE}{$nr}{$_} = 1
		}
	}
		
	### find loops that are not part of other loops
	my %skip;
	foreach my $loop1 (keys % { $s->{NR2END_UNIQUE} }) {
		my $c1 = scalar keys % { $s->{NR2END_UNIQUE}{$loop1} };
		foreach my $loop2 (keys % { $s->{NR2END_UNIQUE} }) {
			next if $loop1 == $loop2;
			my $c2 = scalar keys % { $s->{NR2END_UNIQUE}{$loop2} };
			if ($c1 > $c2) {
				my $cc = 0;
				foreach my $p ( keys % { $s->{NR2END_UNIQUE}{$loop2} }) {
					$cc++ if $s->{NR2END_UNIQUE}{$loop1}{$p}
				}
				### make skip list	
				$skip{$loop1} = 1 if $cc == $c2;
			}
		}
	}
	
	
	### preformat the BREAK_LOOP_OK structure if LOOP_BREAK_STATUS is not 3 (manually selected loop breaks)
	foreach my $loop (keys % { $s->{NR2END_UNIQUE} }) {
		next if $skip{$loop};
		my @p = nsort keys % { $s->{NR2END_UNIQUE}{$loop} };
		$_ = join '==', @p;							
		if ($self->{FAM}{LOOP_BREAK_STATUS}{$fam} == 2) {			
			$self->{FAM}{BREAK_LOOP_OK}{$fam}{$_} = 1;
		}
		elsif ($self->{FAM}{LOOP_BREAK_STATUS}{$fam} == 0) {
			$self->{FAM}{BREAK_LOOP_OK}{$fam}{$_} = 0
		}
	}
}


# Read and process haplotype information from different sources
#==============
sub ReadHaplo {
#==============	
	my (%arg) = @_;
	open (FH, "<" , $arg{-file}) or (ShowInfo("$!: $arg{-file}", 'warning'), return );
		my @file = (<FH>);
	close FH;

	unless (@file) { ShowInfo("$arg{-file} has no data !", 'warning'); return undef }
	my $h1;
	my %haplo;
	my %map;
	my %merlin_unknown = ( qw / ? 1 . 1 / );
	
	### read multiple times searching for given family
	### sample IDs are substituted during processing
	### only haplotypes from those individuals inside pedigree files are imported
	### and only if the sample name matches exact
	foreach my $fam (nsort keys % { $self->{FAM}{PED_ORG} }) {	
		my $found_fam = 0;
		
		### SIMWALK -> one family - one file		
		if ($arg{-format} eq 'SIMWALK') {
			for (my $i = 0; $i < $#file,; $i++) {
				$_ = $file[$i];
				if (/The results for the pedigree named: $fam/) {
					$found_fam = 1;
					undef $haplo{$fam};
					$h1 = $haplo{$fam}{PID} = {};
				}
				next unless $found_fam;
				if (/^M /) {
					my ($M, $z, $P) = ($_,$file[++$i], $file[++$i] );
					my ($pid, $haplo);
					if ( ($pid, $haplo) = $M =~ /^M (\S+).+\s{7}([0-9@].+[0-9@])\s+$/) {
						$pid = $self->{FAM}{PID2PIDNEW}{$fam}{$pid} or next;
						$h1->{"$pid"}{M}{TEXT} = [ split ' ', $haplo ];
						s/\@/$self->{FAM}{HAPLO_UNKNOWN}{$fam}/ foreach @{$h1->{"$pid"}{M}{TEXT}};
					} else {
						ShowInfo("Having problems in finding maternal haplotype in line\n$M", 'error'); return undef
					}
					if ( ($pid, $haplo) = $P =~ /^P (\S+).+\s{7}([0-9@].+[0-9@])\s+$/) {
						$pid = $self->{FAM}{PID2PIDNEW}{$fam}{$pid} or next;
						$h1->{"$pid"}{P}{TEXT} = [ split ' ', $haplo ];
						s/\@/$self->{FAM}{HAPLO_UNKNOWN}{$fam}/ foreach @{$h1->{"$pid"}{P}{TEXT}};
					} else {
						ShowInfo("Having problems in finding paternal haplotype in line\n$P", 'error'); return undef
					}
				}
			}
		}

		### GENEHUNTER 
		elsif ($arg{-format} eq 'GENEHUNTER') {			
			my $fam;
			for (my $i = 0; $i < $#file,; $i++) {
				$_ = $file[$i];
				chomp;
				next unless $_;
				if (/^\*+\s+(\S+)\s+/) {
					next unless $self->{FAM}{PED_ORG}{$1};
					$fam = $1 ;
					$h1 = $haplo{$fam}{PID} = {};
					next;
				}
				next unless $fam;
				my ($P, $M) = ($_,$file[++$i]);
				my ($pid, undef, undef, undef, $PH)  = split "\t", $P;				
				$pid = $self->{FAM}{PID2PIDNEW}{$fam}{$pid} or next;
				$h1->{$pid}{P}{TEXT} = [ split ' ', $PH ];
				foreach (@{$h1->{$pid}{P}{TEXT}}) { s/0/$self->{FAM}{HAPLO_UNKNOWN}{$fam}/ if $_ eq '0' }
				$M =~ s/\t//g;
				$h1->{$pid}{M}{TEXT} = [ split ' ', $M ];
				foreach (@{$h1->{$pid}{M}{TEXT}}) { s/0/$self->{FAM}{HAPLO_UNKNOWN}{$fam}/ if $_ eq '0' }
			}
		}

		### MERLIN 
		elsif ($arg{-format} eq 'MERLIN') {
			my ($fam, @p);
			
			foreach (@file) {				
				chomp;	
				next unless $_;
				
				### extracting family ID
				if (/^FAMILY\s+(\S+)\s+\[(.+)\]/) {
					undef $fam; undef @p;
					next if $2 eq 'Uninformative';													
					next unless $self->{FAM}{PED_ORG}{$1};
					$fam = $1;					
					$h1 = $haplo{$fam}{PID} = {};
				}				 
				next unless $fam;	
				
				### extracting individual IDs
				if (/\(.+\)/) {					
					@p = ();
					my @pid = split ' ', $_;					
					for ( my $k = 0; $k < $#pid; $k+=2 ) {
						
						my $pid = $self->{FAM}{PID2PIDNEW}{$fam}{$pid[$k]} or next;
						push @p,$pid;
						$h1->{$pid}{M}{TEXT} = [];
						$h1->{$pid}{P}{TEXT} = [];
					}
					next									
				}				
				next unless @p;				
				
				### extracting genotype data
				my @L = split;
				next unless @L; 				  				
				for (my $m = 0; $m <= $#p; $m++ ) {
					my $pid = $p[$m];
					my $z = $L[$m*3]; if ($z =~ /,/) { @_ = split ',',$z; $z = $_[0] };
					$z =~ s/[A-Za-z]//g;
					$z = $self->{FAM}{HAPLO_UNKNOWN}{$fam} if $merlin_unknown{$z};
					push @{$h1->{$pid}{M}{TEXT}}, $z;
					my $g = $L[($m*3)+2]; if ($g =~ /,/) { @_ = split ',',$g; $g = $_[0] };
					$g =~ s/[A-Za-z]//g;
					$g = $self->{FAM}{HAPLO_UNKNOWN}{$fam} if $merlin_unknown{$g};
					push @{$h1->{$pid}{P}{TEXT}}, $g;
				}																
			}						
		}
				
		### ALLEGRO 
		elsif ($arg{-format} eq 'ALLEGRO') {
			foreach (@file) { @_ = split; undef $haplo{$_[0]} if $_[0] }
			for (my $i = 0; $i < $#file; $i++) {
				$_ = $file[$i];
				chomp;
				next unless $_;
				next if /^       /;
				@_ = split; 
				next unless @_;
				next unless $self->{FAM}{PED_ORG}{$_[0]};
				my $fam = $_[0];
				my $p = $self->{FAM}{PID2PIDNEW}{$fam}{$_[1]} or next;
				$haplo{$fam}{PID}{$p}{P}{TEXT} = [ @_[ 6 .. $#_] ];
				@_ = split ' ', $file[++$i]; 
				next unless @_;
				next unless $self->{FAM}{PED_ORG}{$fam};
				$haplo{$fam}{PID}{$p}{M}{TEXT} = [ @_[ 6 .. $#_] ];
			}
		}
	
		else { ShowInfo ("Unknown haplotype file format $arg{-format} !", 'info') ; return undef }   
	}
	
	return unless %haplo;
	
	### produce 'dummy map' when haplotype information are loaded
	### this is replaced later when 'real' map files come in
	foreach my $fam ( keys %haplo ) {
		$self->{FAM}{HAPLO}{$fam} = $haplo{$fam};
		(my $pid) = keys %{ $self->{FAM}{HAPLO}{$fam}{PID} } or next;
		if ( $self->{FAM}{HAPLO}{$fam}{PID}{$pid}{P}{TEXT} ) {
			for my $i ( 0 .. $#{ $self->{FAM}{HAPLO}{$fam}{PID}{$pid}{P}{TEXT} } ) {
				$self->{FAM}{HAPLO}{$fam}{DRAW}[$i] = 1;
				$map{MARKER}[$i] = 'Marker' . sprintf("%02.0f",$i+1) unless $map{MARKER}[$i];
			}
			$self->{FAM}{MAP}{$fam} = \%map;				
		}			
	}
	
	ShuffleFounderColors();
	ProcessHaplotypes();
	RedrawPed();	
	AdjustView() if !$batch;	
	
	1;
}

### Loop breaking adds new individuals. 
### Haplotypes have to be duplicated thus
#========================
sub DuplicateHaplotypes {
#========================
	###in case of duplicated PIDs copy the haplotype information
	foreach my $fam ( keys % { $self->{FAM}{HAPLO} } ) {
		foreach my $pid ( keys %{ $self->{FAM}{HAPLO}{$fam}{PID} } ) {	
			if ($self->{FAM}{DUPLICATED_PID}{$fam}{$pid}) { 
				foreach my $pid_n (keys % { $self->{FAM}{DUPLICATED_PID}{$fam}{$pid} }) {
					$self->{FAM}{HAPLO}{$fam}{PID}{$pid_n}{P}{TEXT}  = [ @ { $self->{FAM}{HAPLO}{$fam}{PID}{$pid}{P}{TEXT} } ];
					$self->{FAM}{HAPLO}{$fam}{PID}{$pid_n}{M}{TEXT}  = [ @ { $self->{FAM}{HAPLO}{$fam}{PID}{$pid}{M}{TEXT} } ];
				}
			}
		}
	}
	1;
}


# Read map files 
#============
sub ReadMap {
#============	
	my (%arg) = @_;
	if ($arg{-file}) {
		open (FHM, "<" , $arg{-file}) or ShowInfo("$! $arg{-file}",'warning') && return;
			while (<FHM>) { ${$arg{-data}} .= $_ } 
		close FHM;
	}
	unless ($arg{-data}) { ShowInfo("No data to read !", 'warning'); return undef }
	
	### for which families the map sould be imported
	### the global flag GLOBAL_MAP_IMPORT leads to import of mapping data for every family
	my @fam = ($self->{GLOB}{CURR_FAM});
	if ($param->{GLOBAL_MAP_IMPORT}) { @fam = keys %{ $self->{FAM}{PED_ORG} } }	
	my %map = ();
	
	### CHR-POS-MARKER Format
	if ($arg{-format} eq '1') {
		my $i = 0; foreach (split "\n", ${$arg{-data}}) {
			next unless $_;
			s/\t/ /g;
			next if /^[#!*\/]|CHR/i;
			my ($chr, $pos, $marker) =  split ' ', $_;
			next if ( ! $chr || ! defined $pos || ! $marker );
			$map{POS}[$i] = $pos;
			$map{MARKER}[$i] = $marker;
			$i++;
		}
	}
	
	### CHR-MARKER-POS
	elsif ($arg{-format} eq '2') {
		my $i = 0; foreach (split "\n", ${$arg{-data}}) {
			next unless $_;
			s/\t/ /g;
			next if /^[#!*\/]|CHR/i;
			my ($chr, $marker, $pos) =  split ' ', $_;
			next if ( ! $chr || ! defined $pos || ! $marker );
			$map{POS}[$i] = $pos;
			$map{MARKER}[$i] = $marker;
			$i++;
		}
	}
	
	### catch wrong positions, converting of , --> . 
	foreach ( @ { $map{POS} } ) {
		s/,/\./g;
		if (/[^-+.0-9]/) {
			ShowInfo("One ore more marker positions are corrupted!\n$_",'warning');
			return undef;
		}
	}
	
	### import map for every family	
	my $sm = scalar @{$map{MARKER}};	
	foreach my $fam (@fam) {		
		my $sc; 
		if ( $self->{FAM}{MAP}{$fam}{MARKER} &&  @{$self->{FAM}{MAP}{$fam}{MARKER}}) { 
			$sc = scalar @{$self->{FAM}{MAP}{$fam}{MARKER}} 
		}		
		if ( $sc && ($sc != $sm) ) {
			
			if ($param->{GLOBAL_MAP_IMPORT}) {
				if (scalar @fam ==1) {
					ShowInfo("This map file consists of more or less marker ($sm) then have been loaded from the haplotype file ($sc) for family $fam!",'warning');
					return undef;
				}
				else {
					ShowInfo("This map file consists of more or less marker ($sm) then have been loaded from the haplotype file ($sc) for family $fam!\n" .
					"You should switch off the 'Global map import' flag if your map file is not valid for every family.",'warning'); next
				}
			}
			else {
				ShowInfo("This map file consists of more or less marker ($sm) then have been loaded from the haplotype file ($sc) for family $fam!",'warning');
				return undef;
			}
		}
		undef $self->{FAM}{MAP}{$fam}{POS};
		undef $self->{FAM}{MAP}{$fam}{MARKER};
		foreach my $pos (@ {$map{POS}}) { push @ { $self->{FAM}{MAP}{$fam}{POS} }, $pos }
		foreach my $marker (@ {$map{MARKER}}) { push @ { $self->{FAM}{MAP}{$fam}{MARKER} }, $marker }
	}
	1;
}


# Reading pedigree information
#============
sub ReadPed {
#============	
	my (%arg) = @_;
	return unless $arg{-file};
	
	undef $self->{GLOB}{IMPORTED_PED};
	my $encoding = '';
	
	### read in first 4 bytes to check for BOM sequence
	my ($bom, $file, $bflag);
	open (IN, "<" , $arg{-file}) or (ShowInfo("$! $arg{-file}",'warning'), return undef);
	binmode IN;
	read(IN, $bom,4);			
	close IN;
	
	### file is emty or truncated
	return unless $bom;
	my %e = (
		ascii => '<',utf8 => '<:utf8', 
		utf16be => '<:encoding(UTF-16BE)',utf16le => '<:encoding(UTF-16LE)',
		utf32be => '<:encoding(UTF-32BE)',utf32le => '<:encoding(UTF-32LE)'
	);		
	
	### HaploPainter deals with BOM/Unicode sequence in a way that it checks for it
	### and if there it will overides the $param->{ENCODING} flag
	if    ($bom =~ /^\xEF\xBB\xBF/) 		{ $bflag=1; $encoding = $e{utf8} }
	elsif ($bom =~ /^\x00\x00\xFE\xFF/) { $bflag=1; $encoding = $e{utf32be}  }
	elsif ($bom =~ /^\xFF\xFE\x00\x00/) { $bflag=1; $encoding = $e{utf32le}  }
	elsif ($bom =~ /^\xFE\xFF/) 				{ $bflag=1; $encoding = $e{utf16be}  }
	elsif ($bom =~ /^\xFF\xFE/) 				{ $bflag=1; $encoding = $e{utf16le}  }
	elsif ($param->{ENCODING}) 		{ $encoding = $e{$param->{ENCODING}} }

	open (FH, $encoding , $arg{-file}) or (ShowInfo("$! $arg{-file}",'warning'), return undef);
		### removing BOM if there
		if ($bflag) {
			if (defined ($_ = <FH>)) {
				s/^\x{FEFF}//; 
				$file .= $_ 
			}
			else {
				ShowInfo("Read error",'warning');
				return undef;
			}
		}
	
		
		while (defined ($_ = <FH>)) {
			$file .= $_
		}
		
		
	close FH;
 
	ShowInfo("File $arg{-file} is emty !", 'warning') unless $file;

	#########################################################################
	### Step 1 : read PedData in ARRAY
	#########################################################################

	my %ped_org;
	my %t = (qw/n 0 N 0 y 1 Y 1 0 0 1 1/);
	
	### LINKAGE format --- delimiter = 'tab' or ';' or 'space' --> must have 6 fields
	### HaploPainter trys to process lines in a way that delimiters are automatically dedected
	
	### Syntax of LINKAGE format
	###
	###	           FAMILY                   [ text ]
	###	           PERSON                   [ text ]
	###	           FATHER                   [ text ]
	###	           MOTHER                   [ text ]
	###	           GENDER                   [ [0 or x], [1 or m] ,[2 or f] ]
	###	           AFFECTION                [ [0 or x], 1,2,3,4,5,6,7,8,9 ]
	
	if ( uc $arg{-format} eq 'LINKAGE' ) {
		foreach my $l (split "\n", $file) {
			next unless $l;
			### signs '#' or '*' or '!' may be used to integrate comments or header rows into the file
			next if $l =~ /^[#!*\/]/;
			$l =~ s/^\s+//; $l =~ s/\s+$//;
			$l =~ s/^;+//; $l =~ s/;+$//;
			
			if ($l =~ /;/) { 
				@_ = split ";" ,$l;
				if (scalar @_ < 6) {$l =~ s/;+//g; @_ = split ' ', $l}	### signs '#' or '*' or '!' may be used to integrate comments or header rows into the file						
			}
			
			elsif ($l =~ /\t/) { 
				@_ = split "\t+" ,$l;				
				if (scalar @_ < 6) {@_ = split ' ', $l}				
			}
			
			else { @_ = split ' ' ,$l }						
			next unless @_;
			next if scalar @_ < 6;
			foreach (@_) { s/^\s+//; s/\s+$// }							
			my $fam = shift @_;
			$fam = '' unless $fam;	
			push @{ $ped_org{$fam} }, [ @_[0..4] ];
		}
	}

	### CSV format --- delimiter = TAB; number of fields are unlimited
	### columns 1 - 6 have same order as LINKAGE format

	###	 0          FAMILY                   [ text ]
	###	 1          PERSON                   [ text ]
	###	 2          FATHER                   [ text ]
	###	 3          MOTHER                   [ text ]
	###	 4          GENDER                   [ [0 or x], [1 or m] ,[2 or f] ]
	###	 5          AFFECTION                [ [0 or x], 1,2,3,4,5,6,7,8,9 ]
	###	 6     0    IS_DECEASED              [ [NULL or 0 or n], [ 1 or y ] ]
	###	 7     1    IS_SAB_OR_TOP            [ [NULL or 0 or n], [ 1 or y ] ]
	###	 8     2    IS_PROBAND               [ [NULL or 0 or n], [ 1 or y ] ]
	###	 9     3    IS_ADOPTED               [ [NULL or 0 or n], [ 1 or y ] ]
	###	10     4    ARE_TWINS                [ NULL, [m or d]_text ]
	###	11     5    ARE_CONSANGUINEOUS       [ NULL, text ]
	###	12     6    TEXT_INSIDE_SYMBOL       [ NULL, char ]
	### 13     7    TEXT_BESIDE_SYMBOL       [ NULL, text ]
	###	14     8    TEXT1_BELOW_SYMBOL       [ NULL, text ]
	###	15     9    TEXT2_BELOW_SYMBOL       [ NULL, text ]
	###	16    10    TEXT3_BELOW_SYMBOL       [ NULL, text ]
	###	17    11    TEXT4_BELOW_SYMBOL       [ NULL, text ]
	###	18    12    TEXT5_BELOW_SYMBOL       [ NULL, text ]
	
	elsif ( uc $arg{-format} eq 'CSV') {
		foreach my $l (split "\n", $file) {
			next unless $l;
			
			### signs '#' or '*' or '!' may be used to integrate comments or header rows into the file
			next if $l =~ /^[#!*\/]/;
			@_ =  split "\t", $l;
			next unless @_;
			if (scalar @_ < 6) {
				@_ = split ' ', $l;
				next if scalar @_ < 6;
			}
			foreach (@_) { s/^\s+//; s/\s+$// ; undef $_ if $_ eq ''}									
			for (6 ..9) { $_[$_] = $t{$_[$_]} if defined $_[$_] }			
			my $fam = shift @_;	
			$fam = '' unless $fam;		
			push @{ $ped_org{$fam} }, [ @_[0..17] ];
		}
	}
		
	unless (%ped_org) { ShowInfo("There are no data to read !", 'warning'); return undef }	
	my $er = CheckPedigreesForErrors(\%ped_org, $arg{-format});
	if ($er) { ShowInfo($er); return undef }
	
	
	### make a copy of $self to restore it in case of family processing errors
	$param->{SELF_BACKUP} = freeze($self);
		
	### families are attached to self if there are new or replaced if already there
	foreach my $fam (nsort keys %ped_org) { 
		foreach (keys % { $self->{FAM} }) { delete $self->{FAM}{$_}{$fam} if defined $self->{FAM}{$_}{$fam}}
		AddFamToSelf($fam);
		$self->{FAM}{PED_ORG}{$fam} = $ped_org{$fam};
		ProcessFamily($fam) or return;
		FindLoops($fam);
		$self->{GLOB}{IMPORTED_PED}{$fam} = 1;
		
		if (scalar keys % { $self->{FAM}{BREAK_LOOP_OK}{$fam} } > 3) {
			$self->{FAM}{LOOP_BREAK_STATUS}{$fam} = 2;
			foreach (keys % {$self->{FAM}{BREAK_LOOP_OK}{$fam} })  {
				$self->{FAM}{BREAK_LOOP_OK}{$fam}{$_} = 1
			}			
		}				
	}

	1;
}

#============================
sub CheckPedigreesForErrors {
#============================
	my ($pedref, $format) = @_;
	my (@er,$er);
	
	### define regex match for every column
	my %check = (
		LINKAGE => {
			0 => '.+', 1 => '.+', 2 => '.+', 3 => '.+', 4 => '[012xmfXMF]{1}', 5 => '[0123456789xX]{1}'			
		},
		CSV => {
			6 => '[0nN1yY]{1}', 7 => '[0nN1yY]{1}', 8 => '[0nN1yY]{1}', 9 => '[0nN1yY]{1}', 
		 10 => 'M|m|D|d_\w+', 11 => '\w+', 12 => '.{1,3}', 13 => '.{1,3}', 14 => '.+'						
		}
	);
	
	foreach my $fam ( keys %$pedref ) {
		
		foreach my $l ( @ { $pedref->{$fam} } ) {
			@_ = ($fam, @$l);
			
			### obligatory check of first 6 columns
			### they are the same for LINKAGE and CSV format
			for (0 .. 5) {
				if ( ! defined $_[$_] || $_[$_] !~ /^$check{LINKAGE}{$_}$/) {
					foreach (@_[0..5]) { $_ = '' unless defined $_ }
					push @er, "COLUMN= " . ($_+1) . "; WRONG_TERM= '$_[$_]'; LINE= '@_[0..5]'\n"; 
				}
			}	
			
			### additionally information in CSV format is checked for regex match
			if ($format eq 'CSV') {								
				for (6 .. 13) {
					if ( defined $_[$_] && $_[$_] !~ /^$check{CSV}{$_}$/) {
						foreach (@_[0..5]) { $_ = '' unless defined $_ }
						push @er, "COLUMN= " . ($_+1) . "; WRONG_TERM='$_[$_]'; LINE= '@_[0..5]'\n"; 
					}
				}				
				if (scalar @_ > 14) {
					for (14 .. scalar @_-1) {
						if ( defined $_[$_]  &&  $_[$_] !~ /^$check{CSV}{14}$/) {
							foreach (@_[0..5]) { $_ = '' unless defined $_ }
							push @er, "COLUMN= " . ($_+1) . "; WRONG_TERM='$_[$_]'; LINE= '@_[0..5]'\n"; 
						}
					}
				}				
			}
		}
	}
	
	if (@er && scalar @er < 20) {
		$er .= $_ foreach @er;		
		$er = "There are errors in this pedigree file!\n\n$er";
	}
	elsif (@er && scalar @er > 20) {
		for ( 0 .. 19 ) { $er .= $er[$_] }
		$er = "There are too many errors in this pedigree file - only some of them are shown!\n\n$er";
	}
	
	return $er;
}

#==================
sub ProcessFamily {
#==================	
	my $fam = shift @_ || $self->{GLOB}{CURR_FAM};
	unless ($fam) { ShowInfo("Achtung : Argumentfehler in Funktion ProcessFamily ", 'error'); return }
	my (@er, $er, %save, %twins, %consang);
	### translate gender values
	my %tgender = (qw/0 0 1 1 2 2 x 0 X 0 m 1 M 1 f 2 F 2/);
	my $ci = $self->{FAM}{CASE_INFO}{$fam} = {};	
	unless ($self->{FAM}{PED_ORG}{$fam}) { ShowInfo("There is no family $fam!",'error'); return undef }

	my $id_counter = 1;	

	### ids of individuals are internally recoded
	foreach my $l (@{$self->{FAM}{PED_ORG}{$fam}}) {
		next unless $l;
		my ($old_sid, $old_fid, $old_mid, $sex, $aff, @sample_info) = @$l;
		my ($sid, $fid, $mid);
		$sex = $tgender{$sex};
		### SID
		if (! $save{$old_sid} ) {
			$sid = $id_counter; 
			$save{$old_sid} = $id_counter;
			$self->{FAM}{PID2PIDNEW}{$fam}{$old_sid}=$id_counter;
			$ci->{PID}{$sid}{'Case_Info_1'} = $old_sid;
			$ci->{COL_TO_NAME}{1} = 'Case_Info_1' ;
			$ci->{COL_NAMES}{Case_Info_1} = 1;		
			$id_counter++;
		}
		$sid = $save{$old_sid};
		
		### FID
		if ($old_fid && ! $save{$old_fid} ) {
			$fid = $id_counter; 
			$save{$old_fid} = $id_counter;
			$ci->{PID}{$fid}{'Case_Info_1'} = $old_fid;
			$self->{FAM}{PID2PIDNEW}{$fam}{$old_fid}=$id_counter;
			$ci->{COL_TO_NAME}{1} = 'Case_Info_1' ;
			$ci->{COL_NAMES}{Case_Info_1} = 1;	
			$id_counter++;
		}
		$fid = $save{$old_fid} || 0;
		
		### MID
		if ($old_mid && ! $save{$old_mid} ) {
			$mid = $id_counter; 
			$save{$old_mid} = $id_counter;
			$ci->{PID}{$mid}{'Case_Info_1'} = $old_mid;
			$self->{FAM}{PID2PIDNEW}{$fam}{$old_mid}=$id_counter;
			$ci->{COL_TO_NAME}{1} = 'Case_Info_1' ;
			$ci->{COL_NAMES}{Case_Info_1} = 1;	
			$id_counter++;
		}
		$mid = $save{$old_mid} || 0;
		
		if ($fid && $mid) {
			
			### father and mother must be different
			if ($fid eq $mid) { push @er, "Father and mother of individual $old_sid are identical!\n"; next }						
			
			### Vater + Mutter jeder Person
			$self->{FAM}{SID2FATHER}{$fam}{$sid} = $fid;
			$self->{FAM}{SID2MOTHER}{$fam}{$sid} = $mid;

			### Kinder der Personen
			$self->{FAM}{CHILDREN}{$fam}{$fid}{$sid} = 1;
			$self->{FAM}{CHILDREN}{$fam}{$mid}{$sid} = 1;

			### Kinder des Paares
			$self->{FAM}{CHILDREN_COUPLE}{$fam}{$fid}{$mid}{$sid} = 1;
			$self->{FAM}{CHILDREN_COUPLE}{$fam}{$mid}{$fid}{$sid} = 1;

			### Partner der Person
			$self->{FAM}{COUPLE}{$fam}{$fid}{$mid} = 1;
			$self->{FAM}{COUPLE}{$fam}{$mid}{$fid} = 1;
			
			### parent node creation
			$_ = join '==', nsort($fid,$mid);
			$self->{FAM}{PARENT_NODE}{$fam}{$_} = [$fid,$mid];								
		}

		### ( bzw FOUNDER Status )
		elsif ( ! $fid && ! $mid  )  { $self->{FAM}{FOUNDER}{$fam}{$sid} = 1 }
		else { push @er, "Error in line - father or mother must not be zero: @$l\n"; next }

		### individuals gender
		$self->{FAM}{SID2SEX}{$fam}{$sid} = $sex;

		### individuals affection status
		$aff = 0 if $aff =~ /^x$/i;
		$self->{FAM}{SID2AFF}{$fam}{$sid} = $aff;

		### sibs and mates
		if ($fid) { 
			$self->{FAM}{SIBS}{$fam}{$fid . '==' . $mid}{$sid} = 1;
		}
		
		### Sample ID
		if (! $self->{FAM}{PID}{$fam}{$sid} ) {
			$self->{FAM}{PID}{$fam}{$sid} = 1;
		}
		else { push @er, "Individual $sid is duplicated!\n" }
		
		my %cit = (
			0 => 'IS_DECEASED', 1 => 'IS_SAB_OR_TOP', 2 => 'IS_PROBAND', 3 => 'IS_ADOPTED', 
			4 => 'ARE_TWINS', 5 => 'ARE_CONSANGUINEOUS', 6 => 'INNER_SYMBOL_TEXT', 7 => 'SIDE_SYMBOL_TEXT'
		);
		
		### sid information that are just stored without major processing at this point
		for (0 .. 4) {
			if ($sample_info[$_]) {
				$self->{FAM}{$cit{$_}}{$fam}{$sid} = $sample_info[$_]				
			}
		}
		
		### INNER_SYMBOL_TEXT and SIDE_SYMBOL_TEXT is just stored
		$self->{FAM}{$cit{6}}{$fam}{$sid} = $sample_info[6] if defined $sample_info[6];				
		$self->{FAM}{$cit{7}}{$fam}{$sid} = $sample_info[7] if defined $sample_info[7];				
		
		### storing twin information for later processing
		if ($sample_info[4]) { $twins{$sample_info[4]}{$sid} = 1 }
		
		### storing consanguine information for later processing
		if ($sample_info[5]) { $consang{$sample_info[5]}{$sid} = 1 }
		
		### storing further case information. They will appear as symbol upper text later		
		for (8 .. 11) {			
			my $col_nr = $_-6;
			my $name = 'Case_Info_' . $col_nr;
			$ci->{PID}{$sid}{$name} = $sample_info[$_];
			$ci->{COL_TO_NAME}{$col_nr} = $name;
			$ci->{COL_NAMES}{$name} = 1;
			$self->{FAM}{CASE_INFO_SHOW}{$fam}{$col_nr} = 1 if defined $sample_info[$_];		
		}
	}

	### some checks ...
	### gender of parents	
	foreach my $sid ( keys % { $self->{FAM}{SID2FATHER}{$fam} } ) {
		my $sid_old = $ci->{PID}{$sid}{Case_Info_1};
		my $fid = $self->{FAM}{SID2FATHER}{$fam}{$sid};
		if ( !$self->{FAM}{PID}{$fam}{$fid}) {
			my $fid_old =  $ci->{PID}{$fid}{Case_Info_1};
			push @er,  "Individual $fid_old is declared as father of $sid_old but there are no other information from $fid_old found!\n";
		}	
	}
	
	foreach my $sid ( keys % { $self->{FAM}{SID2MOTHER}{$fam} } ) {
		my $sid_old = $ci->{PID}{$sid}{Case_Info_1};
		my $mid = $self->{FAM}{SID2MOTHER}{$fam}{$sid};
		if ( !$self->{FAM}{PID}{$fam}{$mid}) {
			my $mid_old =  $ci->{PID}{$mid}{Case_Info_1};
			push @er,  "Individual $mid_old is declared as mother of $sid_old but there are no other information from $mid_old found!\n";
		}	
	}
	
	foreach my $sid ( keys % { $self->{FAM}{SID2FATHER}{$fam} } ) {
		my $sid_old = $ci->{PID}{$sid}{Case_Info_1};
		my $fid = $self->{FAM}{SID2FATHER}{$fam}{$sid};
		my $fid_old = $ci->{PID}{$fid}{Case_Info_1};
		push @er,  "Gender of individual $fid_old should be male, because it has been declarated as father of $sid_old.\n" if defined $self->{FAM}{SID2SEX}{$fam}{$fid} && $self->{FAM}{SID2SEX}{$fam}{$fid} ne '1'	
	}
	foreach my $sid ( keys % { $self->{FAM}{SID2MOTHER}{$fam} } ) {
		my $sid_old = $ci->{PID}{$sid}{Case_Info_1};
		my $mid = $self->{FAM}{SID2MOTHER}{$fam}{$sid};
		my $mid_old = $ci->{PID}{$mid}{Case_Info_1};
		push @er,  "Gender of individual $mid_old should be female, because it has been declarated as mother of $sid_old.\n" if defined $self->{FAM}{SID2SEX}{$fam}{$mid} && $self->{FAM}{SID2SEX}{$fam}{$mid} ne '2'
	}
	### founder without children
	foreach my $founder ( keys % { $self->{FAM}{FOUNDER}{$fam} } ) {
		my $founder_old = $ci->{PID}{$founder}{Case_Info_1};
		push @er,  "Founder individual $founder_old has no children.\n" unless keys %{ $self->{FAM}{CHILDREN}{$fam}{$founder} }
	}
	
	### twins check and storage
	if (%twins) {
		N1:foreach my $k (keys %twins) {
			my @twins = keys %{$twins{$k}} or next;
			if (scalar @twins == 1) {
				my $sib_old = $ci->{PID}{$twins[0]}{Case_Info_1};
				push @er,  "The twin individual $sib_old has no counterpart(s).\n"; next N1
			}
			
			my ($twt, $id) = $k =~ /^(.)_(.+)$/; ### match already proved in RedPed
			$twt = lc $twt;
									
			### are twins truly siblings?
			my ($par, $gender);
			N2:foreach my $sib (@twins) {
				my $sib_old = $ci->{PID}{$sib}{Case_Info_1};
				### twins should not be declared as founder
				if (! $self->{FAM}{SID2FATHER}{$fam}{$sib}) {
					push @er,  "The twin individual $sib_old must not be a founder.\n"; next N1
				}
				$par = $self->{FAM}{SID2FATHER}{$fam}{$sib} . '==' .  $self->{FAM}{SID2MOTHER}{$fam}{$sib} if ! $par;
				$gender = $self->{FAM}{SID2SEX}{$fam}{$sib} if ! $gender;
				### twins should be siblings
				if (! $self->{FAM}{SIBS}{$fam}{$par}{$sib}) {
					push @er,  "The twin individual $sib_old is not a member of the sibling group.\n"; next N1
				}
				### monozygotic twins schould have same gender
				if (( $twt eq 'm') && $self->{FAM}{SID2SEX}{$fam}{$sib} != $gender) {
					push @er,  "The twin individual $sib_old is declared as monozygotic but differs in gender of other twins.\n"; next N1
				}
			
				### store twin information
				$self->{FAM}{SID2TWIN_GROUP}{$fam}{$sib} = $k;
				$self->{FAM}{TWIN_GROUP2SID}{$fam}{$k}{$sib} = 1;
				$self->{FAM}{SID2TWIN_TYPE}{$fam}{$sib} = $twt;
			}						
		}
	}
	
	###consanguine check and storage
	if (%consang) {
		foreach my $k (keys %consang) {
			my @cons = keys %{$consang{$k}} or next;
			@_ = (); foreach (@cons) { push @_, $ci->{PID}{$_}{Case_Info_1} }
			$_ = join ',',@_;
			if (scalar @cons != 2) {
				push @er,  "A consanguinity group can only contain two individuals: $_!"; next
			}
			if (! $self->{FAM}{CHILDREN_COUPLE}{$fam}{$cons[0]}{$cons[1]}) {
				push @er,  "You declared individuals: $_ as consanguineous but they have no offspring!"; next
			}
			
			$self->{FAM}{CONSANGUINE_MAN}{$fam}{$cons[0]}{$cons[1]} = 1;
			$self->{FAM}{CONSANGUINE_MAN}{$fam}{$cons[1]}{$cons[0]} = 1;
		}		
	}
	
	### errors were found -> roll back actions and warn
	if (@er) {
		$self = thaw($param->{SELF_BACKUP}) if $param->{SELF_BACKUP};
		undef $param->{SELF_BACKUP};
		if (scalar @er < 20) { 
			$er .= $_ foreach @er;	
			ShowInfo("There are errors in family $fam!\n\n$er", 'error'); return undef 
		}
		else {
			for ( 0 .. 19 ) { $er .= $er[$_] }
			ShowInfo("There are too many errors in family $fam - only some of them are shown!\n\n$er", 'error'); return undef 
		}
	}
	
	### temporary
	#foreach my $l (@{$self->{FAM}{PED_ORG}{$fam}}) {
	#	next unless $l;
	#	$l->[13] = $self->{FAM}{PID2PIDNEW}{$fam}{$l->[0]};	
	#	$ci->{PID}{$l->[13]}{'Case_Info_2'} = $l->[13];
	#	$self->{FAM}{CASE_INFO_SHOW}{$fam}{2} = 1 ;		
	#}
	
	1;
}


#==================
sub ShuffleColors {
#==================	
	my $fam = shift @_ || $self->{GLOB}{CURR_FAM};
	return unless $fam;
	
	return if  ! $self->{FAM}{HAPLO} || ! $self->{FAM}{HAPLO}{$fam} || ! keys % { $self->{FAM}{HAPLO}{$fam}{PID} };
	my %t;
	my %s = ( $self->{FAM}{HAPLO_UNKNOWN_COLOR}{$fam} => 1, 'NI-0' => 1, 'NI-1' => 1, 'NI-2' => 1, 'NI-3' => 1 );
	### which colors are there  ?
	foreach my $p (keys %{$self->{FAM}{PID}{$fam}}) {
		next unless $self->{FAM}{HAPLO}{$fam}{PID}{$p};
		foreach my $mp ( 'M', 'P' ) {
			foreach (@ { $self->{FAM}{HAPLO}{$fam}{PID}{$p}{$mp}{BAR} }) {
				$s{@$_[1]} = 1 if $self->{FAM}{HAPLO}{$fam}{PID}{$p}{$mp}{SAVE};
				$t{@$_[1]} = @$_[1]
			}
		}
	}

	### make new haplotype colors
	foreach (keys %t) {
		if (! $s{$_} ) {
			$t{$_} = sprintf("#%02x%02x%02x", int(rand(256)),int(rand(256)),int(rand(256)));
		}
	}

	### write back colors
	foreach my $p (keys %{$self->{FAM}{PID}{$fam}}) {
		next unless $self->{FAM}{HAPLO}{$fam}{PID}{$p};
		foreach my $mp ( 'M', 'P' ) {
			foreach  (@ { $self->{FAM}{HAPLO}{$fam}{PID}{$p}{$mp}{BAR} }) {
				@$_[1] = $t{@$_[1]}
			}
		}
	}
}



#================
sub CompleteBar {
#================	
	my ($fam,$a, $aa1, $ba1, $aa2, $ba2) = @_;
	return undef if ! $ba1 || ! $ba2 || ! @$ba1 || ! @$ba2;

	my ($phase, @bar);
	my $un = $self->{FAM}{HAPLO_UNKNOWN}{$fam};
	my $unc = $self->{FAM}{HAPLO_UNKNOWN_COLOR}{$fam};

	### Phase ist nicht definiert -> Vorrücken bis zur ersten informativen Stelle
	### und Phase danach definieren
	for (my $j = 0; $j < scalar @$a; $j++) {
		next if @$aa1[$j] eq @$aa2[$j];
		if (@$a[$j] eq @$aa1[$j]) { $phase = 1 } else { $phase = 2 } last
	}
	### wenn das fehlschlaegt ist der Ganze Haplotyp fuer die Katz
	unless ($phase) {
		push @bar, [ 'NI-0', $unc ] foreach @$a;
		return \@bar
	}

	for (my $i = 0; $i < scalar @$a; $i++) {
		### nicht informative Stelle -> entweder Haplotyp fortfuehren
		### oder, wenn voreingestellt als uninformativ deklarieren
		if (@$a[$i] eq $un) {
			if    ($phase == 1) { push @bar, [ 'NI-1', $$ba1[$i][1] ]	 }
			elsif ($phase == 2) { push @bar, [ 'NI-1', $$ba2[$i][1] ]	 }
		}
		elsif ( (@$aa1[$i] eq @$aa2[$i])  ) {
			if    ($phase == 1) { push @bar, [ 'NI-3', $$ba1[$i][1] ]	 }
			elsif ($phase == 2) { push @bar, [ 'NI-3', $$ba2[$i][1] ]	 }
		}
		else {
			if (@$a[$i] eq @$aa1[$i]) { push @bar, [ 'I', $$ba1[$i][1] ]; $phase = 1 }
			else { push @bar, [ 'I', $$ba2[$i][1] ]; $phase = 2 }
		}
	}
	return \@bar;
}


# Which founder couple come to the family in which generation ?
#============
sub FindTop {
#============
	my $fam = shift @_ || $self->{GLOB}{CURR_FAM};
	my (%Top, $f, $m, $flag);
	P:foreach my $partner ( keys % { $self->{FAM}{SIBS}{$fam} } ) {
		($f, $m) = split '==', $partner;
		
		## find everybody joined in couple group  
		my %P = ( $f => 1, $m => 1);
		W:while (1) {
			undef $flag;
			foreach my $p ( keys %P ) {
				foreach my $c ( keys % { $self->{FAM}{COUPLE}{$fam}{$p} }) {
					if (! $P{$c} ) {$P{$c} = 1; $flag = 1}
				}
			}
			last W unless $flag
		}
			
		foreach my $s (keys %P) {
			foreach	(keys % { $self->{FAM}{COUPLE}{$fam}{$s} } ) {
				if ( (! $self->{FAM}{FOUNDER}{$fam}{$_}) && (! $self->{FAM}{CHILDREN}{$fam}{$s}{$_} ) && ! $self->{FAM}{DUPLICATED_PID_ORIG}{$fam}{$_} ) {
					next P
				}
			}
		}
		
		if ( 
		((defined $self->{FAM}{FOUNDER}{$fam}{$f} or (defined $self->{FAM}{DUPLICATED_PID_ORIG}{$fam}{$f}))) and 
		((defined $self->{FAM}{FOUNDER}{$fam}{$m} or (defined $self->{FAM}{DUPLICATED_PID_ORIG}{$fam}{$m})))
		) {
			my @TOP = ($f,$m);
			ChangeOrder(\@TOP) if ! $param->{SORT_COUPLE_BY_GENDER};
			$Top{$partner} = [ @TOP ];
			$self->{FAM}{STRUK}{$fam} = 	[
									[
										[
											[
												[  @TOP  ],
												[ [@TOP] ],
												[ [@TOP] ],
											]
										]
									]
								];

		}
	}
	
	### are there no founders ? ---> ERROR
	@_ = keys %Top;
	if (! @_) {
		 ShowInfo("There is no founder couple in this family !\nFurther drawing aborted.", 'error'); 
		 return undef;
	}

	### Which founder belong to which generation ??
	### If there are more then one founder couple, this method examine with help of BuildStruk()
	### separate sub family structures and searches for connecting overlapping peoples
	### In some situations this has been shown to fail, future work !
	if ($#_) {
		my %G2P;
		foreach my $c ( sort keys %Top ) {
			$self->{FAM}{STRUK}{$fam} = [
								[
									[
										[
											[ @{$Top{$c}}],
											[$Top{$c} ],
											[$Top{$c} ],
										]
									]
								]
							] ;
			
			$self->{GLOB}{STRUK_MODE} = 1;
			BuildStruk($fam);
			$self->{GLOB}{STRUK_MODE} = 0;
			my $s = $self->{FAM}{STRUK}{$fam};
			### extract persons for each generation
			my $g = 0;
			foreach my $G (@$s) {
				foreach my $S (@$G) {
					foreach my $P (@$S) {
						if ( ref $P ) {							
							foreach my $p ( @{$P->[0]} ) { 
								$p = $self->{FAM}{DUPLICATED_PID_ORIG}{$fam}{$p} if  $self->{FAM}{DUPLICATED_PID_ORIG}{$fam}{$p};
								$G2P{$c}{$g}{$p} = 1 
							}
						} else {  
							$P = $self->{FAM}{DUPLICATED_PID_ORIG}{$fam}{$P} if  $self->{FAM}{DUPLICATED_PID_ORIG}{$fam}{$P};
							$G2P{$c}{$g}{$P} = 1 
						}
					}
				} $g++
			}
		}

		### find individual intersection and generation relationship
		my %calc;
		C1:foreach my $c1 ( keys %G2P ) {
			foreach my $G1 ( keys %{$G2P{$c1} } ) {
				foreach my $p1 ( keys %{$G2P{$c1}{$G1} } ) {
					C2:foreach my $c2 ( keys %G2P ) {
						next if $c2 eq $c1;
						foreach my $G2 ( keys %{$G2P{$c2} } ) {
							foreach my $p2 ( keys %{$G2P{$c2}{$G2} } ) {
								if ($p1 eq $p2) {
									if (! %calc) {
										$calc{$G1}{$c1} = 1;
										$calc{$G2}{$c2} = 1;
									} else {
										foreach my $g ( keys %calc ) {
											if ($calc{$g}{$c1}) {
												my $diff = $g-$G1;
												$calc{$G2+$diff}{$c2} = 1
											}
											if ($calc{$g}{$c2}) {
												my $diff = $g-$G2;
												$calc{$G1+$diff}{$c1} = 1
											}
										}
									}
									next C2
								}
							}
						}
					}
				}
			}
		}
		
		### declaration of founder/generation
		my %save2;
		my ($max) =  sort { $b <=> $a } keys %calc;
		foreach my $g (sort { $b <=> $a } keys %calc) {
			foreach my $c (keys % { $calc{$g} }) {
				if (! $save2{$c}) {
					$self->{FAM}{FOUNDER_COUPLE}{$fam}{$max-$g}{$c} = 1;
					$save2{$c} = 1
				}
			}
		}
		### Sollte eigentlich nicht mehr vorkommen ... 
		unless ($self->{FAM}{FOUNDER_COUPLE}{$fam}{0}) {
			ShowInfo("There is no founder couple in generation 1 !",'error');
			return undef;
		}
		
		### multiple mates can be cleared ... see method SetCouple()
		my %save;
		foreach my $g ( keys % { $self->{FAM}{FOUNDER_COUPLE}{$fam} } ) {
			foreach my $coup ( keys % { $self->{FAM}{FOUNDER_COUPLE}{$fam}{$g} } ) {
				my ($p1, $p2) = split '==', $coup;			
				my %P = ( $p1 => 1, $p2 => 1);
				W:while (1) {
					undef $flag;
					foreach my $p ( keys %P ) {
						foreach my $c ( keys % { $self->{FAM}{COUPLE}{$fam}{$p} }) {
							if (! $P{$c} ) {$P{$c} = 1; $flag = 1}
						}
					}
					last W unless $flag
				}
				foreach (keys %P) { 
					if ($save{$_}) {delete $self->{FAM}{FOUNDER_COUPLE}{$fam}{$g}{$coup} } 
					else { $save{$_} = 1 }								
				}								
			}
		}
		### work arround for special case of multiple couple group which is deleted for generation 0
		if (keys % { $self->{FAM}{FOUNDER_COUPLE}{$fam} } && ! keys % { $self->{FAM}{FOUNDER_COUPLE}{$fam}{0} }) {
			my $lg;
			foreach my $g (sort { $a <=> $b } keys % { $self->{FAM}{FOUNDER_COUPLE}{$fam} }) {
				if (keys % { $self->{FAM}{FOUNDER_COUPLE}{$fam}{$g} }) {
					$lg = $g if ! defined $lg;
					$self->{FAM}{FOUNDER_COUPLE}{$fam}{$g-$lg} = $self->{FAM}{FOUNDER_COUPLE}{$fam}{$g};
					delete $self->{FAM}{FOUNDER_COUPLE}{$fam}{$g}
				}
				
			}
		}		
		
		### set up founder couples in {STRUK}
		$self->{FAM}{STRUK}{$fam} = [[]];
		my $s = $self->{FAM}{STRUK}{$fam}[0];
		my @couples = keys % { $self->{FAM}{FOUNDER_COUPLE}{$fam}{0} };	
		foreach (@couples) {
			my ($p1, $p2) = split '==', $_;
			($p1, $p2) = ($p2, $p1) if int(rand(2));
			my $Next_S = [];
			push @$s, $Next_S;
			if (scalar (keys % { $self->{FAM}{COUPLE}{$fam}{$p1} }) > 1) { push @$Next_S, SetCouples($fam,$p1) }
			else { push @$Next_S, SetCouples($fam,$p2) }
		}
	}
	1;
}

### change order of elements in an array
### input=output= reference to array
#================
sub ChangeOrder {
#================	
	my $array = shift;
	return if ! $array || ! @$array;
	return if scalar @$array == 1;
	my $fam = $self->{GLOB}{CURR_FAM};
	### do not mix this array but sort it by Case_Info_1
	if ($param->{SORT_BY_PEDID}) {
		my %s; foreach (@$array) {		
			$s{$self->{FAM}{CASE_INFO}{$fam}{PID}{$_}{'Case_Info_1'}} = $_
		}
	
		@$array = ();
		foreach (nsort keys %s) {push @$array, $self->{FAM}{PID2PIDNEW}{$fam}{$_} }

	}
	### mix this array 
	else {
		for (my $i = @$array; --$i; ) {
			my $j = int rand ($i+1);
			@$array[$i,$j] = @$array[$j,$i];
		}
	}
}



############################################################################
#  family specific variable $self->{$struk} as nested array of arrays of ...
#  holds pedigree structure Hierachy: Generation->Sibgroups->Person/Couples
#
#
#  $struk =
#  [
#     [ Generation 1 ],                generation
#     [ Generation 2 ],                
#     [                                
#        [ Sibs 1 ],                    extended sibgroup
#        [ Sibs 2 ],                   
#        [                             
#           Pid 1,                      sib without spouses
#           [ Partner 1 ],              sib with spouses
#           [                       
#              [ p1, p2, p3 ],          drawing order of multiple mates in one row
#              [ p1, p3 ] , [ p2, p3 ]  reflects sib groups drived from [ p1, p2, p3 ]
#              [ p1, p2 ] , [ p2, p3 ]  reflects *real* drawing order of sib groups
#           ]
#        ]
#     ]
#  ]
#
#
###########################################################################


#===============
sub BuildStruk {
#===============	
	my $fam = shift @_ || $self->{GLOB}{CURR_FAM};
	my $G = 0;
	my $EndFlag = 1;
	my $s = $self->{FAM}{STRUK}{$fam};
	my $skip = {};
	my $skip2 = {};
	### clear generation from $G+1
	$#{$s}=0;
	while ($EndFlag) {
		my $Next_G = []; push @$s, $Next_G;
		undef $EndFlag;
		foreach my $S ( @ { $s->[$G] } ) {
			foreach my $P ( @$S ) {
				if ( ref $P ) {
					$EndFlag = 1;
					foreach my $p ( @ { $P->[1] } ) {					
						my @children; 
						foreach my $child (keys % { $self->{FAM}{CHILDREN_COUPLE}{$fam}{@$p[0]}{@$p[1]} }) {
							my $r = SetCouples($fam,$child);													
							if (ref $r) { 
								my $c = join '==', nsort @ { $r->[0] };
																																		
								my $founder = 0; 							
								foreach my $coupl ( @ { $r->[0] } ) { if (!$self->{FAM}{FOUNDER}{$fam}{$coupl}) { $founder++ } }
																							
								### checking if child must be skipped, because it belongs to a multiple mate node
								### and this node would be drawn multiple times depending from number of non-founders inside
								if (!$self->{GLOB}{STRUK_MODE} && ($founder >1)) {																	
									if ($skip->{$child} && ($skip->{$child} == ($founder-1))) { push @children, $child }								
									else { $skip->{$_}++ foreach @ { $r->[0] } }
								}
								else { 									
									push @children, $child if ! $skip2->{$child};
									$skip2->{$_}++ foreach @ { $r->[0] }
								}
							}
							else { push @children, $child }
						}
						
						ChangeOrder(\@children) if @children;
						my $Next_S = []; if (@children) { push @$Next_G, $Next_S }
						foreach my $child (@children) {
							$_ = SetCouples($fam,$child);
							push @$Next_S, $_ if $_;
						}
					}
				}
			}
		}
		### if there are new founder couples in that generation (see FindTop )
		### they have to be integrated as new starting point
		if (! $self->{GLOB}{STRUK_MODE} && $self->{FAM}{FOUNDER_COUPLE}{$fam}{$G+1}) {
			foreach ( keys % { $self->{FAM}{FOUNDER_COUPLE}{$fam}{$G+1} } ) {
				my ($p1) = split '==', $_;
				my $Next_S = [];			
				### new founder couple are randomly placed inside $Next_g	
				splice (@$Next_G, int(rand(scalar @$Next_G+1)), 0, $Next_S);
				push @$Next_S, SetCouples($fam,$p1);
			}
		}
		$G++;
	}
	pop @$s;
}


# Zeichen-Matrix anlegen. Von STRUK ausgehend werden die relativen Zeichenpositionen
# aller Personen generationsweise festgelegt (P2XY/YX2P)
# Next layer after {STRUK} is {MATRIX} -> translation into relative XY Positions
#================
sub BuildMatrix {
#================	
	my $fam = shift @_ || $self->{GLOB}{CURR_FAM};
	my $s  = $self->{FAM}{STRUK}{$fam};
	$self->{FAM}{MATRIX}{$fam} = {};
	$self->{FAM}{PID_SAVE}{$fam} = {};
	my $mt = $self->{FAM}{MATRIX}{$fam};
	my $x = my $x0 = 0;
	my $y = my $y0 = 0;
	my $xs	= $self->{FAM}{X_SPACE}{$fam};
	my $ys	= $self->{FAM}{Y_SPACE}{$fam};
	my %save;
	
	### Zeichenmatrix anlegen
	foreach my $G (@$s) {
		foreach my $S (@$G) {
			foreach my $P (@$S) {
				if ( ref $P ) {
					foreach my $p ( @{$P->[0]} ) {
						next if $save{$p};
						$mt->{P2XY}{$p}   = { X => $x, Y => $y };
						$mt->{YX2P}{$y}{$x} = $p;
						$x+= $xs+1;
						$save{$p} = 1;
					}
				} else {
					next if $save{$P};				
					$mt->{P2XY}{$P}   = { X => $x, Y => $y };
					$mt->{YX2P}{$y}{$x} = $P;
					$x+= $xs+1;
					$save{$P} = 1;
				}
			}
		}
		$x = $x0;
		$y+= $ys
	}
}




# Export all pedigrees in given format
#================
sub BatchExport {
#==============
	my $suffix = shift @_ or return undef;
	ShowInfo("Please select working directory and a basic file name without suffix.\nGraphic outputs will be extended by pedigree identifiers.\n\n");
	my $file = $mw->getSaveFile(-initialfile => 'pedigree') or return;	
	my $curr_fam = $self->{GLOB}{CURR_FAM};
	foreach my $fam (nsort keys % { $self->{FAM}{PED_ORG} }) {
		my $file = File::Spec->catfile( dirname($file), basename($file) . '_' . $fam . '.' . $suffix);	
		if (! $self->{FAM}{MATRIX}{$fam}) { 
			$self->{GLOB}{CURR_FAM} = $fam;
			DoIt() 
		}
		DrawOrExportCanvas(-modus => $suffix, -fam => $fam, -file => $file);
	}	
	$self->{GLOB}{CURR_FAM} = $curr_fam if $curr_fam;
}


# adapt canvas scroll region and center/fit views
#===============
sub AdjustView {
#===============	
	shift @_ if ref $_[0];
	my %arg = @_;
	my $fam = $self->{GLOB}{CURR_FAM} or return;
	my $c = $canvas;
	my $s = $param->{SHOW_GRID};
	my $z = $self->{FAM}{ZOOM}{$fam};
	return if $batch;
	
	
	$param->{SHOW_GRID} = 0;
	ShowGrid();
	
	my @bx = $c->bbox('all');
	
	unless (@bx) {
		$param->{SHOW_GRID} = $s;
		ShowGrid();				
		return;
	}
	
	### scrollbar size ( left and right point of slider position, is between 0 and 1)
	my @xv = $c->xview;
	my @yv = $c->yview;
	
	my @sc = $c->Subwidget('canvas')->cget(-scrollregion);

	### size of bounding box
	my $xbd = $bx[2]-$bx[0];
	my $ybd = $bx[3]-$bx[1];
			
	### relative size of sliding window (size of slider --> if 1 then sliding window = whole canvas)
	my $xvd = $xv[1]-$xv[0];
	my $yvd = $yv[1]-$yv[0];

	### size of canvas scrollable region
	my $xsd = $sc[2]-$sc[0];
	my $ysd = $sc[3]-$sc[1];
	
	### sliding window size
	my $wx = $xsd*$xvd;
	my $wy = $ysd*$yvd;
	
	### scroll buffer
	my ($scrx, $scry) = ($xbd, $ybd);
	if ($scrx < (1.5*$wx)) { $scrx = 1.5*$wx }
	if ($scry < (1.5*$wy)) { $scry = 1.5*$wy }
	
	### just shift to middle point of the drawing wihout zoom
	if (! $arg{-fit}) {
		$c->configure(-scrollregion => [ $bx[0]-$scrx, $bx[1]-$scry, $bx[2]+$scrx, $bx[3]+$scry ]);
		
		my @xv = $c->xview;
		my @yv = $c->yview;
		
		$c->xviewMoveto(0.5-(($xv[1]-$xv[0])*0.5));
		$c->yviewMoveto(0.5-(($yv[1]-$yv[0])*0.5));		
		
	}
	### Center and fit the view
	elsif ( $arg{-fit} eq 'center') {					
		
		### adapt zoom factor to bounding box + 10% border
		if ($ybd && $wy) {
			if  ($xbd/$ybd > $wx/$wy) {
				$self->{FAM}{ZOOM}{$fam} *= $wx/$xbd*0.9} else { $self->{FAM}{ZOOM}{$fam} *= $wy/$ybd*0.9  
			}
		}
		
		RedrawPed();
		
		### adapt canvas scroll region to fit the drawing bounding box and center scrollbars
		my @bx = $canvas->bbox('all');
		
		my $xbd = $bx[2]-$bx[0];
		my $ybd = $bx[3]-$bx[1];
		
		my ($scrx, $scry) = ($xbd, $ybd);
		if ($scrx < (1.5*$wx)) { $scrx = 1.5*$wx }
		if ($scry < (1.5*$wy)) { $scry = 1.5*$wy }
	
		$c->configure(-scrollregion => [ $bx[0]-$scrx, $bx[1]-$scry, $bx[2]+$scrx, $bx[3]+$scry ]);
						
		my @xv = $c->xview;
		my @yv = $c->yview;
						
		$c->xviewMoveto(0.5-(($xv[1]-$xv[0])*0.5));
		$c->yviewMoveto(0.5-(($yv[1]-$yv[0])*0.5));
		
	}
	### Zooming to cursor position
	elsif ($arg{-fit} eq 'to_button') {				
		
		### last stored canvas position in respect of corresponding cursor position
		my $x = $self->{GLOB}{X_CANVAS};
		my $y = $self->{GLOB}{Y_CANVAS};				
		
		### center canvas scrollregion to that coordinates				
		my @sc = ( $x-$scrx, $y-$scry, $x+$scrx, $y+$scry );
		$c->configure(-scrollregion => \@sc);
		
		my @xv = $c->xview;
		my @yv = $c->yview;
						
		my $xvd = $xv[1]-$xv[0];
		my $yvd = $yv[1]-$yv[0];
		  	
		my $xsd = $sc[2]-$sc[0];
		my $ysd = $sc[3]-$sc[1];
					
		my $wx = $xsd*$xvd;
		my $wy = $ysd*$yvd;
						
		my $x_diff = $x-$c->canvasx($self->{GLOB}{X_SCREEN});		
		my $y_diff = $y-$c->canvasy($self->{GLOB}{Y_SCREEN});
		
		my $prop_x = 1-$xvd;
		my $prop_y = 1-$yvd;
		
		my $moveto_x = $xv[0] + ( ($prop_x*$x_diff)/($xsd-$wx) );
		my $moveto_y = $yv[0] + ( ($prop_y*$y_diff)/($ysd-$wy) );
		
		$c->xviewMoveto($moveto_x);	
		$c->yviewMoveto($moveto_y);						
	}
	
	$param->{SHOW_GRID} = $s;
	ShowGrid();
	
	### Store canvas and scrollbar positions
	StoreDrawPositions()
		
}

#=============
sub ShowGrid {
#=============	
	my $fam = shift @_ || $self->{GLOB}{CURR_FAM};
	return unless $fam;
	my $z = $self->{FAM}{ZOOM}{$fam};
	if ($param->{SHOW_GRID}) {
		$canvas->createGrid( 0,0, $self->{FAM}{GITTER_X}{$fam}*$z,$self->{FAM}{GITTER_Y}{$fam}*$z,-lines => 1, -fill => 'grey90', -tags => 'GRID');
		$canvas->Subwidget('canvas')->lower('GRID');
	} else {
		$canvas->delete('GRID')
	}
}


#=======================
sub DrawOrExportCanvas {
#=======================
	my %arg = @_;
	my $fam = $arg{-fam} || $self->{GLOB}{CURR_FAM};
	my $z = $self->{FAM}{ZOOM}{$fam};
	my $l = $self->{FAM}{LINE_WIDTH}{$fam};
	my $lnc = $self->{FAM}{LINE_COLOR}{$fam};
	my $de = $self->{FAM}{DRAW_ELEMENTS}{$fam}{CANVAS};
	my $d = $self->{FAM}{LINES}{$fam};
	my $f1 = $self->{FAM}{FONT1}{$fam};
	### draw pedigree in a Tk widget 
	if (! $arg{-modus}) {
		
		### clear canvas and rebuild grid
		$canvas->delete('all');
		ShowGrid();
		
		### Lines betwwen symbols			
		foreach my $parent_node (keys %{$d->{COUPLE}}) {
			foreach my $ln ( @{$d->{COUPLE}{$parent_node}} ) {					
				$canvas->createLine(@$ln, -width => $l*$z,-fill => $lnc)						
			}
		}			
		foreach my $id (keys %{$d->{SIB}}) {
			foreach my $ln ( @{$d->{SIB}{$id}} ) {					
				$canvas->createLine(@$ln, -width => $l*$z,-fill => $lnc)						
			}
		}			
		foreach my $id (keys %{$d->{COUPLE_SIB}}) {
			foreach my $ln ( @{$d->{COUPLE_SIB}{$id}} ) {					
				$canvas->createLine(@$ln, -width => $l*$z,-fill => $lnc)						
			}
		}
		foreach my $id (keys %{$d->{TWIN_LINES}}) {
			foreach my $ln ( @{$d->{TWIN_LINES}{$id}} ) {					
				$canvas->createLine(@$ln, -width => $l*$z,-fill => $lnc)						
			}
		}
		
		### Drawing male SYMBOL Elements
		foreach my $r (@ { $de->{SYM_MALE} }) { $canvas->createRectangle(@$r) }		
		### Drawing female SYMBOL Elements
		foreach my $r (@ { $de->{SYM_FEMALE} }) { $canvas->createOval(@$r) }		
		### Drawing stillbirth SYMBOL Elements
		foreach my $r (@ { $de->{SYM_STILLBIRTH} }) { $canvas->createPolygon(@$r) }		
		### Drawing unknown SYMBOL Elements
		foreach my $r (@ { $de->{SYM_UNKNOWN} }) { $canvas->createPolygon(@$r) }					
		#### Drawing  Text elements
		foreach my $e (qw/  INNER_SYMBOL_TEXT CASE_INFO TITLE PROBAND_TEXT MARK_TEXT SAB_GENDER/ ) {foreach my $r (@ { $de->{$e} }) { $canvas->createText(@$r)}}			
		### Drawing live status line
		foreach my $r (@ { $de->{LIVE_LINE} }) { $canvas->createLine(@$r) }		
		### Haplotype Bar not informative
		foreach my $r (@ { $de->{HAP_BAR_NI} }) { $canvas->createRectangle(@$r) }	
		### Haplotype Bar
		foreach my $r (@ { $de->{HAP_BAR} }) { $canvas->createRectangle(@$r) }							
		### Haplotype Bounding Box
		foreach my $r (@ { $de->{HAP_BOX} }) { $canvas->createRectangle(@$r) }							
		### Haplotype Text
		foreach my $e (qw /HAP_TEXT MAP_MARKER_LEFT MAP_MARKER_RIGHT MAP_POS_LEFT MAP_POS_RIGHT /) {
			foreach my $r (@ { $de->{$e} }) { $canvas->createText(@$r) }					
		}	
		### Arrows
		foreach my $r (@ { $de->{ARROWS} }) { $canvas->createLine(@$r) }				
		### Adopted lines
		foreach my $r (@ { $de->{IS_ADOPTED} }) { $canvas->createLine(@$r) }	
	
		#foreach my $r (@ { $self->{FAM}{CROSS_CHECK}{$fam} }) { $canvas->createOval(@$r) }		
		$mw->configure(-title => "HaploPainter V.$self->{GLOB}{VERSION}  -[Family $fam]");
		$param->{INFO_LABEL}->configure(-text => '') ;
	}
	

	elsif ($arg{-modus} eq 'CSV') {
		my $file_name = $arg{-file} or return undef;
		my %t = (
			ascii => '>',
			utf8    => '>:raw:encoding(UTF-8):crlf:utf8',
			utf16le => '>:raw:encoding(UTF-16LE):crlf:utf8',
		);
		
		my $encoding = $t{$param->{ENCODING}};
		
		my @fams;
		if ($arg{-fammode}) { @fams = nsort keys % { $self->{FAM}{PED_ORG} }}
		else { @fams = $fam }
		return unless @fams;
		
		open (FH, $encoding, $file_name) or (ShowInfo("$!: $file_name", 'warning'), return );
			my $head = join "\t", (qw / *FAMILY PERSON FATHER MOTHER GENDER AFFECTION IS_DECEASED IS_SAB_OR_TOP 
			IS_PROBAND IS_ADOPTED ARE_TWINS ARE_CONSANGUINEOUS INNER_SYMBOL_TEXT SIDE_SYMBOL_TEXT 
			LOWER_SYMBOL_TEXT1 LOWER_SYMBOL_TEXT2 LOWER_SYMBOL_TEXT3 LOWER_SYMBOL_TEXT4/);
			
			### write byte of marke (BOM) for Unicode encoded files
			if ( ($param->{ENCODING} ne 'ascii') && $param->{WRITE_BOM}) { print FH "\x{FEFF}" }			
			print FH "$head\n";
						
			foreach my $fam (@fams) {
				my %ped;
				foreach my $r ( @ { $self->{FAM}{PED_ORG}{$fam} } ) {
					next unless $r;
					@_ = @$r;
					foreach (@_[0..17]) { $_ = '' unless defined $_ };
					$ped{$_[0]} = [@_]
				}
				foreach my $pid (nsort keys %ped) {
					@_ = @ { $ped{$pid} }; shift @_;
					$_ = join "\t", ($fam,$pid, @_);
					print FH "$_\n"; 
				}
			}
		close FH;
	}
	
	### render graphic using cairo from the gtk2 environment
	else {				
		return unless $fam;
		my ($surface, $cairo);
		my $file_name = $arg{-file} or return undef;
			
		### exploring coordinates of all drawing elements to find out "bounding box"
		my (%x, %y);	
		foreach my $e (keys %$de) {			
			foreach my $r (@ { $de->{$e} }) {
				for (my $i=0; $i < scalar @$r-1; $i+=2) {
					if ($r->[$i] !~ /^-[a-z]/) {
						$x{$r->[$i]} = 1;
						$y{$r->[$i+1]} = 1
					}
				}
			}
		}
		my @x = sort { $a <=> $b } keys %x;
		my @y = sort { $a <=> $b } keys %y;
		
		### bounding box dimension
		my ($x1_bb, $x2_bb, $y1_bb, $y2_bb) = (@x[0,-1], @y[0,-1]);

		### calculate scale factor based on paper size, paper orientation 
		### and zoom factor during calculation of canvas coordinates
		my $x_pap_mm = $param->{PAPER_SIZE}{$self->{GLOB}{PAPER}}{X};
		my $y_pap_mm = $param->{PAPER_SIZE}{$self->{GLOB}{PAPER}}{Y};
		($x_pap_mm,$y_pap_mm) = ($y_pap_mm,$x_pap_mm)	if $self->{GLOB}{ORIENTATION} =~ /^landscape$/i;	
		
		### Resolution in settings
		my $res = $self->{GLOB}{RESOLUTION_DPI};
		
		### for postscript set to 72 (1 inch = 72 points)
		$res = 72 if $arg{-modus} eq 'PS';
		
		### paper dimension have n pixels at given resolution
		my $x_pap_pix = $x_pap_mm/25.4*$res;
		my $y_pap_pix = $y_pap_mm/25.4*$res;
		
		### border as set in global settings
		my $pix_border = $self->{GLOB}{BORDER}/25.4*$res;				
		
		#### bounding box x and y direction
		my $diffx = $x2_bb - $x1_bb;
		my $diffy = $y2_bb - $y1_bb;

		#### scale factor assuming x adaption versus y direction
		my $f = $x_pap_pix/$diffx;
		$f = $y_pap_pix/$diffy if ($diffy*$f) > $y_pap_pix;	
				
		#### find out dimension of text
		$surface = Cairo::ImageSurface->create ('argb32', $x_pap_pix,$y_pap_pix);		
		$cairo = Cairo::Context->create($surface);						
		$cairo->scale($f,$f);			
		
		### any  text
		foreach my $e (qw /SAB_GENDER MARK_TEXT HAP_TEXT MAP_MARKER_LEFT MAP_MARKER_RIGHT MAP_POS_LEFT MAP_POS_RIGHT TITLE CASE_INFO INNER_SYMBOL_TEXT PROBAND_TEXT/) {
			foreach my $r (@ { $de->{$e} }) {
				my $x = $r->[0]; my $y = $r->[1];	
				my $weight = ''; $weight = 'Bold' if $r->[7][2] eq 'bold'; 
				my $style = ''; $style = 'Italic' if $r->[7][3] eq 'italic';
				my $font_descr_str = join " ", ($r->[7][0], $weight, $style, $r->[7][1]/(96/72) );
				my $pango_layout = Gtk2::Pango::Cairo::create_layout ($cairo);     	
				my $font_desc = Gtk2::Pango::FontDescription->from_string($font_descr_str);
				$pango_layout->set_font_description($font_desc);
				$pango_layout->set_markup ($r->[5]);		
				my ($width, $height) = $pango_layout->get_pixel_size();	
				$x{ $x-($width/2) } = 1;$x{ $x+($width/2) } = 1;
				$y{ $y-($height/2)} = 1;$y{ $y+($height/2) } = 1;	
			}
		}
		undef $surface;
		undef $cairo;
		
		@x = sort { $a <=> $b } keys %x;
		@y = sort { $a <=> $b } keys %y;
		
		### bounding box dimension
		($x1_bb, $x2_bb, $y1_bb, $y2_bb) = (@x[0,-1], @y[0,-1]);
		
		### bounding box x and y direction
		$diffx = $x2_bb - $x1_bb;
		$diffy = $y2_bb - $y1_bb;
		
		### scale factor assuming x adaption versus y direction
		$f = $x_pap_pix/$diffx;
		$f = $y_pap_pix/$diffy if ($diffy*$f) > $y_pap_pix;	
		
		### adding border scaled by factor f
		for ($x1_bb, $y1_bb) { $_-= $pix_border/$f }
		for ($x2_bb, $y2_bb) { $_+= $pix_border/$f }
		
		### recalculating bounding box
		$diffx = $x2_bb - $x1_bb;
		$diffy = $y2_bb - $y1_bb;	
		
		### recalculating factor
		$f = $x_pap_pix/$diffx;
		$f = $y_pap_pix/$diffy if ($diffy*$f) > $y_pap_pix;	
				
		### create differrent surfaces for different output formats
		if ($arg{-modus} eq 'PNG') {				
			$surface = Cairo::ImageSurface->create ('argb32', $x_pap_pix,$y_pap_pix);						
		}
					
		elsif ($arg{-modus} eq 'SVG') {
			$surface = Cairo::SvgSurface->create ($file_name, $x_pap_pix,$y_pap_pix);
		}
		
		elsif ($arg{-modus} eq 'PDF') {
			$surface = Cairo::PdfSurface->create ($file_name, $x_pap_pix,$y_pap_pix);
		}
		elsif ($arg{-modus} eq 'PS') {
			$surface = Cairo::PsSurface->create ($file_name, $diffx,$diffy);
			$surface->set_size($x_pap_pix,$y_pap_pix);
			$surface->dsc_begin_setup;
			$surface->dsc_begin_page_setup;		 			
		} 		 		
		else { ShowInfo("Unknown file format $arg{-modus}\n"), return }
		
		### create cairo context object and scale it to factor $f
		$cairo = Cairo::Context->create($surface);
		$cairo->scale($f,$f);			
		
		### Background box if set in $self->{FAM}{EXPORT_BACKGROUND}
		if ($self->{FAM}{EXPORT_BACKGROUND}{$fam}) {		
			$cairo->set_source_rgb (GetCairoCol($self->{GLOB}{BACKGROUND}));	
			$cairo->paint();			
		}
		
		
		### Lines between COUPLE symbols
		$cairo->set_line_width($l*$z);	
		$cairo->set_source_rgb (GetCairoCol($lnc));
		foreach my $parent_node (keys %{$d->{COUPLE}}) {
			foreach my $ln ( @{$d->{COUPLE}{$parent_node}} ) {
				$cairo->move_to($ln->[0]-$x1_bb,$ln->[1]-$y1_bb);
				for (my $i=2; $i< scalar @$ln-1;$i+=2) {
					$cairo->line_to($ln->[$i]-$x1_bb, $ln->[$i+1]-$y1_bb);
				}
				$cairo->stroke;
			}
		}		  			 
		### Lines between SIB symbols			
		foreach my $id (keys %{$d->{SIB}}) {
			foreach my $ln ( @{$d->{SIB}{$id}} ) {
				$cairo->move_to($ln->[0]-$x1_bb,$ln->[1]-$y1_bb);
				for (my $i=2; $i< scalar @$ln-1;$i+=2) {
					$cairo->line_to($ln->[$i]-$x1_bb, $ln->[$i+1]-$y1_bb);
				}
				$cairo->stroke;
			}
		}		
		### Lines between COUPLE_SIB symbols			
		foreach my $id (keys %{$d->{COUPLE_SIB}}) {
			foreach my $ln ( @{$d->{COUPLE_SIB}{$id}} ) {
				$cairo->move_to($ln->[0]-$x1_bb,$ln->[1]-$y1_bb);
				for (my $i=2; $i< scalar @$ln-1;$i+=2) {
					$cairo->line_to($ln->[$i]-$x1_bb, $ln->[$i+1]-$y1_bb);
				}
				$cairo->stroke;
			}
		}	
		
		### Lines between TWIN symbols			
		foreach my $id (keys %{$d->{TWIN_LINES}}) {
			foreach my $ln ( @{$d->{TWIN_LINES}{$id}} ) {
				$cairo->move_to($ln->[0]-$x1_bb,$ln->[1]-$y1_bb);				
				$cairo->line_to($ln->[2]-$x1_bb,$ln->[3]-$y1_bb);				
				$cairo->stroke;
			}
		}	
		
		### male symbols
		foreach my $r (@{$de->{SYM_MALE}}) { 	  
			my ($x1, $y1, $x2, ) = ($r->[0]-$x1_bb, $r->[1]-$y1_bb, $r->[2]-$r->[0]);
			$cairo->set_line_width($r->[5]);
			$cairo->rectangle($x1, $y1, $x2, $x2);
			$cairo->set_source_rgb (GetCairoCol($r->[9]));
			$cairo->fill_preserve;		  	  	
			$cairo->set_source_rgb (GetCairoCol($r->[7]));
			$cairo->stroke;	
		}				
			 
		### female symbols
			foreach my $r (@{$de->{SYM_FEMALE}}) {
				my ($x1, $y1, $x2) = (   (($r->[0]+$r->[2])/2)-$x1_bb,  (($r->[1]+$r->[3])/2)-$y1_bb, ($r->[2]-$r->[0])/2  );
				my $lw = $r->[5];
				$cairo->set_line_width($lw);
				$cairo->arc($x1, $y1, $x2, 0,360);				
				$cairo->set_source_rgb (GetCairoCol($r->[9]));								
				$cairo->fill_preserve;
				$cairo->set_source_rgb (GetCairoCol($r->[7]));
				$cairo->stroke;		
			}		 
		
		### unknown gender symbols
		foreach my $r (@{$de->{SYM_UNKNOWN}}) {
			my ($x1,$y1,$x2,$y2,$x3,$y3,$x4,$y4 ) = @$r[0..7];
			for ($x1,$x2,$x3,$x4) { $_-=$x1_bb }
			for ($y1,$y2,$y3,$y4) { $_-=$y1_bb }
			$cairo->set_line_width($r->[9]);
			$cairo->move_to($x1, $y1);
			$cairo->line_to($x2, $y2);
			$cairo->line_to($x3, $y3);
			$cairo->line_to($x4, $y4);
			$cairo->close_path();
			$cairo->set_source_rgb (GetCairoCol($r->[13]));
			$cairo->fill_preserve;
			$cairo->set_source_rgb (GetCairoCol($r->[11]));
			$cairo->stroke;	
		}
	
		### stillbirth symbol
		foreach my $r (@{$de->{SYM_STILLBIRTH}}) {
			my ($x1,$y1,$x2,$y2,$x3,$y3) = @$r[0..5];
			for ($x1,$x2,$x3) { $_-=$x1_bb }
			for ($y1,$y2,$y3) { $_-=$y1_bb }
			$cairo->set_line_width($r->[7]);
			$cairo->move_to($x1, $y1);
			$cairo->line_to($x2, $y2);
			$cairo->line_to($x3, $y3);
			$cairo->close_path();
			$cairo->set_source_rgb (GetCairoCol($r->[11]));
			$cairo->fill_preserve;		  	
			$cairo->set_source_rgb (GetCairoCol($r->[9]));
			$cairo->stroke;
		}
	
		### live status line
		foreach my $r (@ { $de->{LIVE_LINE} }) { 
			my ($x1,$y1,$x2,$y2) = @$r[0..3];
			for ($x1,$x2) { $_-=$x1_bb }
			for ($y1,$y2) { $_-=$y1_bb }
			$cairo->set_line_width($r->[5]);
			$cairo->move_to($x1, $y1);
			$cairo->line_to($x2, $y2);
			$cairo->set_source_rgb (GetCairoCol($r->[7]));
			$cairo->stroke; 
		}
		
		
		### IS_ADOPTED
		foreach my $r (@ { $de->{IS_ADOPTED} }) { 
			my ($x1,$y1,$x2,$y2,$x3,$y3,$x4,$y4) = @$r[0..7];
			for ($x1,$x2,$x3,$x4) { $_-=$x1_bb }
			for ($y1,$y2,$y3,$y4) { $_-=$y1_bb }
			$cairo->set_line_width($r->[9]);
			$cairo->move_to($x1, $y1);
			$cairo->line_to($x2, $y2);
			$cairo->line_to($x3, $y3);
			$cairo->line_to($x4, $y4);
			$cairo->set_source_rgb (GetCairoCol($r->[11]));
			$cairo->stroke; 
		}
		
		### haplotype bars
		for my $bar (qw /HAP_BAR_NI HAP_BAR/) {
			foreach my $r (@ { $de->{$bar} }) { 
				my ($x1, $y1, $x2, $y2 ) = ($r->[0]-$x1_bb, $r->[1]-$y1_bb, $r->[2]-$r->[0], $r->[3]-$r->[1]);
				$cairo->rectangle($x1, $y1, $x2, $y2);
				$cairo->set_line_width($r->[5]);
				if ($r->[9]) {
					$cairo->set_source_rgb (GetCairoCol($r->[9]));
					$cairo->fill_preserve;
				}
				$cairo->set_source_rgb (GetCairoCol($r->[7]));
				$cairo->stroke;	
			}
		}
		
		### haplotype bounding boxes
		foreach my $r (@ { $de->{HAP_BOX} }) { 
			my ($x1, $y1, $x2, $y2 ) = ($r->[0]-$x1_bb, $r->[1]-$y1_bb, $r->[2]-$r->[0], $r->[3]-$r->[1]);
			$cairo->rectangle($x1, $y1, $x2, $y2);
			$cairo->set_line_width($r->[5]);
			$cairo->set_source_rgb (GetCairoCol($r->[7]));
			#$cairo->fill_preserve;
			#$cairo->set_source_rgb (GetCairoCol($r->[7]));
			$cairo->stroke;	
		}
		
		
		### any  text
		foreach my $e (qw /SAB_GENDER MARK_TEXT HAP_TEXT MAP_MARKER_LEFT MAP_MARKER_RIGHT MAP_POS_LEFT MAP_POS_RIGHT TITLE CASE_INFO INNER_SYMBOL_TEXT PROBAND_TEXT/) {
			foreach my $r (@ { $de->{$e} }) {
				my $x = $r->[0]-$x1_bb;
				my $y = $r->[1]-$y1_bb;
				#print "ALIGN=$r->[3]\n";
				### 96dpi/72dpi is empirical found to right scale the panda font size
				### may be this code has to be adopted to current display resolution?
				my $weight = ''; $weight = 'Bold' if $r->[7][2] eq 'bold'; 
				my $style = ''; $style = 'Italic' if $r->[7][3] eq 'italic';
				my $font_descr_str = join " ", ($r->[7][0], $weight, $style, $r->[7][1]/(96/72) );
				my $pango_layout = Gtk2::Pango::Cairo::create_layout ($cairo);     	
				my $font_desc = Gtk2::Pango::FontDescription->from_string($font_descr_str);
				$pango_layout->set_font_description($font_desc);
				$pango_layout->set_markup ($r->[5]);
				
				my ($width, $height) = $pango_layout->get_pixel_size();
				
				### pango set_alignment does not work!?!?!
				### work arround
				if ($r->[3] eq 'w') { $cairo->move_to($x,$y-($height/2)) }
				elsif ($r->[3] eq 'e') { $cairo->move_to($x-$width,$y-($height/2)) }
				elsif ($r->[3] eq 'center') { $cairo->move_to($x-($width/2),$y-($height/2)) }
				
				$cairo->set_source_rgb (GetCairoCol($r->[9]));
				Gtk2::Pango::Cairo::show_layout ($cairo, $pango_layout);
			}	
		}
		
		### proband arrow
		foreach my $r (@ { $de->{ARROWS} }) { 
			my ($x1,$y1,$x2,$y2) = @$r[0..3];
			for ($x1,$x2) { $_-=$x1_bb }
			for ($y1,$y2) { $_-=$y1_bb }
			$cairo->set_line_width($r->[5]);
			$cairo->set_source_rgb (GetCairoCol($r->[7]));
			
			### drawing arrow shape using trigonomic functions and the assumption
			### that the arrow angle beeing 45 degree		
			my $d1=$self->{FAM}{ARROW_DIST1}{$fam}*$z;
			my $d2=$self->{FAM}{ARROW_DIST2}{$fam}*$z;
			my $d3=$self->{FAM}{ARROW_DIST3}{$fam}*$z;
						
			my $b = sqrt ( ($d2*$d2) + ($d3*$d3) );
			my $c = sqrt ( ($d3*$d3) + (($d2-$d1)*($d2-$d1)) );			
			my ($aq,$bq,$cq) = ($d1*$d1,$b*$b,$c*$c);						
			my $alpha2 = 45 - rad2deg(acos(($aq+$bq-$cq)/(2*$d1*$b)));			
			my $x3 = cos(deg2rad($alpha2))*$b;
			my $y3 = sqrt ($bq-($x3*$x3));
			my $x4 = sqrt (($d1*$d1)/2);
			
			$cairo->move_to($x1, $y1);
			$cairo->line_to($x2-$x4, $y2+$x4);
			$cairo->stroke; 			
			$cairo->line_to($x2-$x3, $y2+$y3);
			$cairo->line_to($x2,$y2);
			$cairo->line_to($x2-$y3, $y2+$x3);
			$cairo->line_to($x2-$x4, $y2+$x4);
			$cairo->close_path();			
			$cairo->fill;
			$cairo->stroke; 						
		}
		
		### create graphics
		$cairo->show_page;
				
		### PNG slightly differ in syntax --> extra command 
		if ($arg{-modus} eq 'PNG') {			
			$surface->write_to_png ($file_name);		
		}
		
		### otherwise the file handle is not closed properly!
		### (i found no methods for destroying or finishing cairo/surface ...)
		undef $surface;
		undef $cairo;		
	}
	1;
}

#================
sub GetCairoCol {
#================
	my $col = shift @_ || return (0,0,0);
	if ($col =~ /^#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/) {
		return (hex($1)/255,hex($2)/255,hex($3)/255);
	}
	ShowInfo("Error reading color: $col - is substituted to black!\n");
	return (0,0,0)
}

	
### set all drawing elements in respect of haplotypes
#=============
sub SetHaplo {
#=============
	my $fam = shift @_ || $self->{GLOB}{CURR_FAM};
	my $m = $self->{FAM}{MATRIX}{$fam};
	my $h = $self->{FAM}{HAPLO}{$fam} or return;
	return unless keys %{$self->{FAM}{HAPLO}{$fam}};
	my $z = $self->{FAM}{ZOOM}{$fam};
	my $f1 = $self->{FAM}{FONT1}{$fam};
	my $fh = $self->{FAM}{FONT_HAPLO}{$fam};
	my $l = $self->{FAM}{SYMBOL_LINE_WIDTH}{$fam};
	my $lnc = $self->{FAM}{LINE_COLOR}{$fam};
	my $lw = $self->{FAM}{HAPLO_TEXT_LW}{$fam};
	my $td1 = ($fh->{SIZE}*$z) + ($lw*$fh->{SIZE}*$z);
	my $font1  =  [ $f1->{FAMILY},$f1->{SIZE}*$z ,$f1->{WEIGHT},$f1->{SLANT} ];
	my $font_haplo =  [ $fh->{FAMILY},$fh->{SIZE}*$z , $fh->{WEIGHT}, $fh->{SLANT} ];
	my $hw = $self->{FAM}{HAPLO_WIDTH}{$fam};
	my $hwni = $self->{FAM}{HAPLO_WIDTH_NI}{$fam};
	my $hs = $self->{FAM}{HAPLO_SPACE}{$fam};
	my $hlw = $self->{FAM}{HAPLO_LW}{$fam};
	my $un = $self->{FAM}{HAPLO_UNKNOWN}{$fam};
	my $de = $self->{FAM}{DRAW_ELEMENTS}{$fam}{CANVAS};
	my $sz = $self->{FAM}{SYMBOL_SIZE}{$fam};
	my $gy = $self->{FAM}{GITTER_Y}{$fam};
	my $ys = $self->{FAM}{Y_SPACE}{$fam};					
	my $lsy = $self->{FAM}{LINE_SIBS_Y}{$fam};
	my $yse = $self->{FAM}{Y_SPACE_EXTRA}{$fam};
	
	### find most left and right X matrix position for legend drawing
	my @X_GLOB; push @X_GLOB,( keys % { $m->{YX2P}{$_} }) foreach keys % { $m->{YX2P} }; 
	@X_GLOB = sort { $a <=> $b } @X_GLOB;

	### find last valid index ($i2) and number of drawing elements ($i3)
	my ($i1, $i2, $i3) = (0,0,0);
	foreach (@{$h->{DRAW}}) {
		if ($_) { $i2 = $i1 ; $i3++ } $i1++
	}

	### find disabled or hidden colors
	my %Hide;
	if ($self->{FAM}{PED_ORG}{$fam}) {
		foreach (@{$self->{FAM}{PED_ORG}{$fam}}) {
			next unless $_;
			my $pid = @$_[0];
			for my $mp ( 'M','P') {
				if ($h->{PID}{$pid}{$mp}{HIDE}) {
					foreach ( @{$h->{PID}{$pid}{$mp}{BAR}}) {
						$Hide{@$_[1]} = 1 if @$_[1] ne $self->{FAM}{HAPLO_UNKNOWN_COLOR}{$fam}
					}
				}
			}
		}
	}
	
	### number of text elements to draw below symbols
	my $ccc=1; for (5,4,3,2,1) { if ($self->{FAM}{CASE_INFO_SHOW}{$fam}{$_}) { $ccc=$_+1;last  } }
	my $text = $f1->{SIZE}*$ccc*$z;				

	### drawing haplotypes and legend
	foreach my $Y (keys % { $m->{YX2P} }) {
		my @X = sort { $a <=> $b } keys % { $m->{YX2P}{$Y} };
		my $cy = $Y*$self->{FAM}{GITTER_Y}{$fam} + $lw*$z*2;
		my $curr_y = ($cy+$sz)*$z;
		
		foreach my $X (@X) {
			my $p = $m->{YX2P}{$Y}{$X};		
			my $cx = $X*$self->{FAM}{GITTER_X}{$fam};		
			
			### haplotypes as bar
			if ( $h->{PID}{$p}{P}{TEXT} ) {
				if ($self->{FAM}{SHOW_HAPLO_BAR}{$fam}) {
					my $td = $td1;
					my ($col, $inf, $ncol, $ninf, $out, $lr, $fill, $al, $x1, $x2, $y1, $y2 );
						
					### shrink bar to value of Y_SPACE 
					if (! BarTextOk()) {									
						my $free_space = (($gy*$ys)-(2*$sz)-$text-$lsy-$yse)*$z;
						$td = $free_space/$i3;
					}

					my $y = $curr_y + $text + $td;
					
					foreach my $PM ( 'P', 'M') {
						my ($f, $cc, $nif, $nexti) = (1,0,0);
						if ($PM eq 'M') { $lr = -1 } else { $lr = 1 }

						for (my $i=0; $i <= $i2;$i++) {
							next unless $self->{FAM}{HAPLO}{$fam}{DRAW}[$i];
							$al = $h->{PID}{$p}{$PM}{TEXT}[$i];
							($inf,$col) = @{ $h->{PID}{$p}{$PM}{BAR}[$i] };
							next if $Hide{$col};
							### draw bars as not-informative
							### NI-0: no genotypes there at all
							### NI-1: several lost genotypes
							### NI-2: genotyped but declared as not-informative by hand 
							### NI-3: genotyped but declared as not-informative automatically
							if (
								( ($inf eq 'NI-0') && $self->{FAM}{SHOW_HAPLO_NI_0}{$fam} ) ||
								( ($inf eq 'NI-1') && $self->{FAM}{SHOW_HAPLO_NI_1}{$fam} ) ||
								( ($inf eq 'NI-2') && $self->{FAM}{SHOW_HAPLO_NI_2}{$fam} ) ||
								( ($inf eq 'NI-3') && $self->{FAM}{SHOW_HAPLO_NI_3}{$fam} )
							) {
								$out = $fill = $self->{FAM}{HAPLO_UNKNOWN_COLOR}{$fam};
								if ( $self->{FAM}{SHOW_HAPLO_TEXT}{$fam} && ! $self->{FAM}{ALLELES_SHIFT}{$fam}) { $cc++; next }
								($x1, $x2) = ( ($cx-($lr*$hs)-($hwni/2))*$z, ($cx-($lr*$hs)+($hwni/2))*$z );
								$nif = 1;
							} else {
								$out = $fill = $col;
								$nif = 0;
								($x1, $x2) = ( ($cx-($lr*$hs)-($hw/2))*$z, ($cx-($lr*$hs)+($hw/2))*$z );
							}

							undef $fill if ! $self->{FAM}{FILL_HAPLO}{$fam};
							
							
							if (! $self->{FAM}{HAPLO_SEP_BL}{$fam}) {								
								if ($i != $i2) {
									### next element to draw
									my $i4; for ($i4=$i+1; $i4 <= $i2;$i4++) {last if $self->{FAM}{HAPLO}{$fam}{DRAW}[$i4]}
									($ninf,$ncol) = @{ $h->{PID}{$p}{$PM}{BAR}[$i4] };
									if (
										( ($ninf eq 'NI-0') && $self->{FAM}{SHOW_HAPLO_NI_0}{$fam} ) ||
										( ($ninf eq 'NI-1') && $self->{FAM}{SHOW_HAPLO_NI_1}{$fam} ) ||
										( ($ninf eq 'NI-2') && $self->{FAM}{SHOW_HAPLO_NI_2}{$fam} ) ||
										( ($ninf eq 'NI-3') && $self->{FAM}{SHOW_HAPLO_NI_3}{$fam} )
									) { $nexti = 1 }
									else { $nexti = 0 }
									if ( ($col eq $ncol) && ($nif == $nexti) ) {
										$f++; $cc++; next
									} else {
										($y1, $y2) = ( $y + ($cc-$f)*$td,  $y + $cc*$td ); $f = 1
									}
								} else {
									($y1, $y2) = ( $y + ($cc-$f)*$td,  $y + $cc*$td ); $f = 1
								}
							} else {
								($y1, $y2) = ( $y + ($cc-1)*$td,  $y + $cc*$td )
							}
							### different arrays for informative versus not-informative haplotypes
							### to facilitate right drawing order 
							if (! $nif) {																
								push @ { $de->{HAP_BAR} }, [
									$x1 , $y1, $x2 , $y2,
									-width => $hlw*$z, -outline => $out,
									-fill => $fill, -tags => [ "BAR", "BAR1-$p" ]
								]
							}
							else {
								push @ { $de->{HAP_BAR_NI} }, [
									$x1 , $y1, $x2 , $y2,
									-width => $hlw*$z, -outline => $out,
									-fill => $fill, -tags => [ "BAR", "BAR1-$p"]
								]
							}
							
							$cc++;
	
						}
					}
				}

				### haplotypes as text
				if ($self->{FAM}{SHOW_HAPLO_TEXT}{$fam}) {
					my $cc = 0;
					my $col;
					my $sh = $self->{FAM}{ALLELES_SHIFT}{$fam};
					my ($x1, $x2) = ( ($cx-$hs-$sh)*$z, ($cx+$hs+$sh)*$z );
					
					#my $y = $pmy[-1] + $f1->{SIZE}*$z + $td1/2;
					my $y = $curr_y + $text + $td1/2;
				
					### paternal haplotype
					for (my $i=0; $i <= $#{ $h->{PID}{$p}{P}{TEXT} };$i++) {
						next unless $self->{FAM}{HAPLO}{$fam}{DRAW}[$i];
						my $inf = $h->{PID}{$p}{P}{BAR}[$i][0];
						
						if (
								$self->{FAM}{SHOW_COLORED_TEXT}{$fam} && ! (
								( ($inf eq 'NI-0') && $self->{FAM}{SHOW_HAPLO_NI_0}{$fam} ) ||
								( ($inf eq 'NI-1') && $self->{FAM}{SHOW_HAPLO_NI_1}{$fam} ) ||
								( ($inf eq 'NI-2') && $self->{FAM}{SHOW_HAPLO_NI_2}{$fam} ) ||
								( ($inf eq 'NI-3') && $self->{FAM}{SHOW_HAPLO_NI_3}{$fam} ) )
							) { $col = $h->{PID}{$p}{P}{BAR}[$i][1] } else { $col = $fh->{COLOR} }
						
						
						$h->{PID}{$p}{P}{TEXT}[$i] =~ s/@/$self->{FAM}{HAPLO_UNKNOWN}{$fam}/;
						push @ { $de->{HAP_TEXT} }, [
							$x1, $y+ ($cc*$td1),
							-anchor => 'center', -text => $h->{PID}{$p}{P}{TEXT}[$i] ,
							-font => $font_haplo, -fill => $col, -tags => [ 'ALLEL', "ALLEL-P-$i-$p" ]
						];
						$cc++
					}


					$cc = 0;
					### maternal haplotype
					for (my $i=0; $i <= $#{ $h->{PID}{$p}{M}{TEXT} };$i++) {
						next unless $self->{FAM}{HAPLO}{$fam}{DRAW}[$i];
						my $inf = $h->{PID}{$p}{M}{BAR}[$i][0];
						if (
								$self->{FAM}{SHOW_COLORED_TEXT}{$fam} && ! (
								( ($inf eq 'NI-0') && $self->{FAM}{SHOW_HAPLO_NI_0}{$fam} ) ||
								( ($inf eq 'NI-1') && $self->{FAM}{SHOW_HAPLO_NI_1}{$fam} ) ||
								( ($inf eq 'NI-2') && $self->{FAM}{SHOW_HAPLO_NI_2}{$fam} ) ||
								( ($inf eq 'NI-3') && $self->{FAM}{SHOW_HAPLO_NI_3}{$fam} ) )
							) { $col = $h->{PID}{$p}{M}{BAR}[$i][1] } else { $col = $fh->{COLOR} }
						
						
						$h->{PID}{$p}{P}{TEXT}[$i] =~ s/@/$self->{FAM}{HAPLO_UNKNOWN}{$fam}/;
						$h->{PID}{$p}{M}{TEXT}[$i] =~ s/@/$self->{FAM}{HAPLO_UNKNOWN}{$fam}/;
						push @ { $de->{HAP_TEXT} }, [
							$x2, $y + ($cc*$td1),
							-anchor => 'center', -text => $h->{PID}{$p}{M}{TEXT}[$i],
							-font => $font_haplo, -fill => $col, -tags => [ 'ALLEL', "ALLEL-M-$i-$p" ]
						];
						$cc++
					}
				}

				### haplotypes as bounding box
				if ($self->{FAM}{SHOW_HAPLO_BBOX}{$fam} && $h->{PID}{$p}{BOX}) {
					my ($x1, $x2) = (($cx-$self->{FAM}{BBOX_WIDTH}{$fam})*$z,($cx+$self->{FAM}{BBOX_WIDTH}{$fam})*$z);
					my ($y1, $y2);
					my $f = 1;
					my $cc = 0;
					my $td = $td1;
					if (! $self->{FAM}{SHOW_HAPLO_TEXT}{$fam} ) {
						$td = ($self->{FAM}{Y_SPACE}{$fam}-3.5)*$self->{FAM}{GITTER_Y}{$fam}*$z/$i3;
					}
					
					#my $y = $pmy[-1] + $f1->{SIZE}*$z + $td;
					my $y = $curr_y + $text + $td;
					
					for (my $i=0; $i <= $i2;$i++) {
						next unless $self->{FAM}{HAPLO}{$fam}{DRAW}[$i];
						unless ($h->{PID}{$p}{BOX}[$i]) { $cc++; next }
 						if ($i != $i2) {
							if ( $h->{PID}{$p}{BOX}[$i+1] ) {
								$f++; $cc++; next
							} else {
								($y1, $y2) = ( $y + ($cc-$f)*$td,  $y + $cc*$td ); $f = 1
							}
						} else {
							($y1, $y2) = ( $y + ($cc-$f)*$td,  $y + $cc*$td ); $f = 1
						}
												
						push @ { $de->{HAP_BOX} }, [
							$x1, $y1, $x2, $y2,
							-width => $hlw*$z, -outline => '#000000',
							-tags => [ 'BOX', "BOX-$p", 'TAG' ]
						];	
						$cc++
					}
				}
			}
		}

		### map information
		if (@X && $self->{FAM}{MAP}{$fam}) {
			my $cc = 0;
			
			
			#my $y = $pmy[-1] + $f1->{SIZE}*$z + $td1/2;
			my $y = $curr_y + $text + $td1/2;
			
			if ($self->{FAM}{SHOW_MARKER}{$fam}) {
				
				### marker left side
				if ($self->{FAM}{SHOW_LEGEND_LEFT}{$fam}) {
					$cc = 0; 
					my $x;
					if ($self->{FAM}{ALIGN_LEGEND}{$fam}) {
						$x = ( ($X_GLOB[0]*$self->{FAM}{GITTER_X}{$fam}) - $self->{FAM}{LEGEND_SHIFT_LEFT}{$fam} ) * $z;
					} else {
						$x = ( ($X[0]*$self->{FAM}{GITTER_X}{$fam}) - $self->{FAM}{LEGEND_SHIFT_LEFT}{$fam} ) * $z;
					}												 
					for (my $i=0; $i <= $#{ $self->{FAM}{MAP}{$fam}{MARKER} };$i++) {
						next unless $self->{FAM}{HAPLO}{$fam}{DRAW}[$i];
						push @ { $de->{MAP_MARKER_LEFT} }, [	
							$x, $y + ($cc*$td1),
							-anchor => 'w', -text => $self->{FAM}{MAP}{$fam}{MARKER}[$i] ,
							-font => $font_haplo, -fill => $fh->{COLOR}
						];
						$cc++
					}
				}
				
				### marker right side
				if ($self->{FAM}{SHOW_LEGEND_RIGHT}{$fam}) {
					$cc = 0; 
					my $x;
					if ($self->{FAM}{ALIGN_LEGEND}{$fam}) {
						$x = ( ($X_GLOB[-1]*$self->{FAM}{GITTER_X}{$fam}) + $self->{FAM}{LEGEND_SHIFT_RIGHT}{$fam} ) * $z;
					} else {
						$x = ( ($X[-1]*$self->{FAM}{GITTER_X}{$fam}) + $self->{FAM}{LEGEND_SHIFT_RIGHT}{$fam} ) * $z;
					}																	 
					for (my $i=0; $i <= $#{ $self->{FAM}{MAP}{$fam}{MARKER} };$i++) {
						next unless $self->{FAM}{HAPLO}{$fam}{DRAW}[$i];
						push @ { $de->{MAP_MARKER_RIGHT} }, [	
							$x, $y + ($cc*$td1),
							-anchor => 'w', -text => $self->{FAM}{MAP}{$fam}{MARKER}[$i] ,
							-font => $font_haplo, -fill => $fh->{COLOR}
						];
						$cc++
					}
				}			
			
			}

			if ($self->{FAM}{SHOW_POSITION}{$fam}) {				
				
				### position left side
				if ($self->{FAM}{SHOW_LEGEND_LEFT}{$fam}) {
					$cc = 0; 
					my $x;
					if ($self->{FAM}{ALIGN_LEGEND}{$fam}) {
						$x = ( ($X_GLOB[0]*$self->{FAM}{GITTER_X}{$fam}) - $self->{FAM}{LEGEND_SHIFT_LEFT}{$fam} + $self->{FAM}{MARKER_POS_SHIFT}{$fam} ) * $z;
					} else {
						$x = ( ($X[0]*$self->{FAM}{GITTER_X}{$fam}) - $self->{FAM}{LEGEND_SHIFT_LEFT}{$fam} + $self->{FAM}{MARKER_POS_SHIFT}{$fam} ) * $z;
					}

					for (my $i=0; $i <= $#{ $self->{FAM}{MAP}{$fam}{POS} };$i++) {
						next unless $self->{FAM}{HAPLO}{$fam}{DRAW}[$i];
						push @ { $de->{MAP_POS_LEFT} }, [	
							$x, $y + ($cc*$td1),
							-anchor => 'e', -text => sprintf("%6.2f",$self->{FAM}{MAP}{$fam}{POS}[$i]) ,
							-font => $font_haplo, -fill => $fh->{COLOR}
						];
						$cc++
					}
				}
				
				### position right side
				if ($self->{FAM}{SHOW_LEGEND_RIGHT}{$fam}) {
					$cc = 0; 
					my $x;
					if ($self->{FAM}{ALIGN_LEGEND}{$fam}) {
						$x = ( ($X_GLOB[-1]*$self->{FAM}{GITTER_X}{$fam}) + $self->{FAM}{LEGEND_SHIFT_RIGHT}{$fam} + $self->{FAM}{MARKER_POS_SHIFT}{$fam} ) * $z;
					} else {
						$x = ( ($X[-1]*$self->{FAM}{GITTER_X}{$fam}) + $self->{FAM}{LEGEND_SHIFT_RIGHT}{$fam} + $self->{FAM}{MARKER_POS_SHIFT}{$fam} ) * $z;
					}

					for (my $i=0; $i <= $#{ $self->{FAM}{MAP}{$fam}{POS} };$i++) {
						next unless $self->{FAM}{HAPLO}{$fam}{DRAW}[$i];
						push @ { $de->{MAP_POS_RIGHT} }, [	
							$x, $y + ($cc*$td1),
							-anchor => 'e', -text => sprintf("%6.2f",$self->{FAM}{MAP}{$fam}{POS}[$i]) ,
							-font => $font_haplo, -fill => $fh->{COLOR}
						];
						$cc++
					}
				}
				
			}
		}
	}
}

# Aligning 
#================
sub AlignMatrix {
#================	
	my $fam = shift @_ || $self->{GLOB}{CURR_FAM};
	my $s = $self->{FAM}{STRUK}{$fam};
	my $m = $self->{FAM}{MATRIX}{$fam};
	my @s;
	my $cc = 1;
	my $cd = 0;
	my $ok = 1;
	my $max_x =  $self->{FAM}{X_SPACE}{$fam} * scalar keys % { $self->{FAM}{PID}{$fam} };
	
	foreach my $Y ( sort { $b <=> $a } keys % { $m->{YX2P} } ) {
		my %Save;
		foreach my $X ( sort { $a <=> $b } keys % { $m->{YX2P}{$Y} } ) {
			my $P = $m->{YX2P}{$Y}{$X} or die "No Person in XY $X $Y\n", Dumper($m);
			if ($X>$max_x) { return 0 }
			my ($fa,$mo) = ($self->{FAM}{SID2FATHER}{$fam}{$P},$self->{FAM}{SID2MOTHER}{$fam}{$P});
			next if ! $fa && ! $mo;
			
			### Geschwister von $P einschliesslich $P
			@s = keys %{$self->{FAM}{CHILDREN_COUPLE}{$fam}{$fa}{$mo}};
			
			my $str; $str .= $_ for @s;
			next if $Save{$str}; $Save{$str} = 1;

			### alle X Koordinaten der Geschwister
			my %k; foreach (@s) { 
				if (! $_ || ! defined $m->{P2XY}{$_}) {
					die Dumper(\@s, $m);
				}
				$k{ $m->{P2XY}{$_}{X} } = $_
			}
			my @sk = sort { $a <=> $b } keys %k;
			
			### translate parents into drawing compatible order in case of multiple mates
			($fa, $mo) = TranslateCoupleGroup($fam, 'FROM_MATRIX', $fa, $mo);
			
			my $Y_f = $m->{P2XY}{$fa}{Y};
			my $kf = $m->{P2XY}{$fa}{X};
			my $km = $m->{P2XY}{$mo}{X};
			my %k2 = ( $kf => $fa, $km => $mo);
			my @ek =  sort { $a <=> $b } keys %k2;
			my $mitte_c = sprintf("%1.0f", ($sk[0]+$sk[-1])/2);
			my $mitte_e = sprintf("%1.0f", ($kf+$km)/2);
			my $diff = $mitte_c-$mitte_e;			

			my $ind = 0;
			my $newpos1 = $sk[0]-$diff;
			my $newpos2 = $ek[0]+$diff;

			if (scalar (keys %{ $self->{FAM}{COUPLE}{$fam}{$k2{$ek[0]}}}) != 1) {
				$ind = 1;
				$newpos2 = $ek[1]+$diff;
			}

			if ( $diff < 0 ) {
				### Shift Kinder nach rechts ->
				ShiftRow($fam,$Y, $k{$sk[0]}, $newpos1);
				$self->{FAM}{PID_SAVE}{$fam}{$k2{$ek[0]}} = 1;
				return 0
			}

			elsif ( $diff > 0 )  {
				### Shift Eltern nach rechts ->
				unless (ShiftRow($fam,$Y_f, $k2{$ek[$ind]}, $newpos2,1)) {next};
				return  0

			}
			$cc++;
		}
	}
	return $cc;
}

#=========================
sub TranslateCoupleGroup {
#=========================
	my ($fam, $modus, $p1, $p2) = @_;
	my (%P, $flag, %ch, @S, @D1, @D2, %SAVE);
	my $m = $self->{FAM}{MATRIX}{$fam};
	my $c = $self->{FAM}{COUPLE}{$fam};
	my $cg = {};
	my $couple_from = join '==', nsort ($p1, $p2);
	
	## find everybody joined in couple group  
	foreach ( keys % { $self->{FAM}{COUPLE}{$fam}{$p1} }) {		
		$P{$_} = 1  if ! $self->{FAM}{CHILDREN}{$fam}{$p1}{$_}
	}
	W:while (1) {
		undef $flag;
		foreach my $p ( keys %P ) {
			foreach my $c ( keys % { $self->{FAM}{COUPLE}{$fam}{$p} }) {
				if (! $P{$c} && ! $self->{FAM}{CHILDREN}{$fam}{$p}{$c}) {
					$P{$c} = 1; $flag = 1
				}
			}
		}
		last W unless $flag
	}
	
	### examine multiple mate situation
	if (scalar keys %P > 2) {
		
		### locate each individual in the actual drawing
		### and store it in a hash sortable by x coordinate
		foreach my $p (keys %P) {
			if ($modus eq 'FROM_CANVAS') {
				my @co = $canvas->coords("SYM-$p") or return ($p1, $p2);								
				my $xm = sprintf("%1.3f", ($co[0]+$co[2])/2); 
				$ch{$xm}{$p} = 1
			}
			elsif ($modus eq 'FROM_MATRIX') { 
				if (! defined $m->{P2XY}{$p} ) {
					die "FROM_MATRIX error at pid $p\n"
				}
				
				$ch{$m->{P2XY}{$p}{X}}{$p} = 1
			}
		}
		
		### X-order of all mates as seen on canvas/matrix
		foreach my $x (sort { $a <=> $b } keys %ch) { 
			foreach my $p (keys % { $ch{$x} }) {
				push @S, $p; 
			}
		}
		
		foreach my $i (0 .. $#S-1) {
			push @D2, [ $S[$i], $S[$i+1] ];
		}
		
		### from @S derived order of couples for example (  [ p1, p3 ], [ p2, p3 ], [ p3, p4 ] )
		### list @S is screened for most right hand free mate
		foreach my $p1 (@S) {
			foreach my $p2 (@S) {
				next if $p1 eq $p2;
				if ($self->{FAM}{CHILDREN_COUPLE}{$fam}{$p1}{$p2} && ! $SAVE{$p1}{$p2} && ! $SAVE{$p2}{$p1}) {				
					my $str = join "==", nsort ($p1,$p2);
					my $last_i = $#D1 + 1;
					if ($str eq $couple_from) {
						return @ { $D2[$last_i] }
					}				
					push @D1, [ $p1, $p2 ];
					$SAVE{$p1}{$p2} = 1;
				}
			}
		}
	}
	return ($p1, $p2);
}



# Row Shift rechts: Shift erfolgt 'gleitend' d.h. Luecken werdend waehrend des
# shifts aufgefuellt
#=============
sub ShiftRow {
#=============	
	my ($fam, $Y, $pid, $NewPos, $flag) = @_;
	my $m = $self->{FAM}{MATRIX}{$fam};
	my $OldPos = $m->{P2XY}{$pid}{X};
	return if $NewPos == $OldPos;
	my (%SaveRow, %Freeze);

	### Wird benoetigt um sich kreuzende Zeichengruppen zu erkennen (shift wird unterbunden)
	foreach my $P (keys % { $self->{FAM}{PID_SAVE}{$fam} }) {
		next if $pid eq $P;
		next if $m->{P2XY}{$P}{Y} != $Y;
		my $X = $m->{P2XY}{$P}{X};
		$Freeze{$X} = $P if $X >= $OldPos;
	}
	(my $XL) = sort { $a <=> $b } keys %Freeze;

	if ($flag && $XL && ( $NewPos >= $XL) ) { return undef }

	foreach my $X (sort { $a <=> $b } keys % { 	$m->{YX2P}{$Y} } ) {
		$SaveRow{$m->{YX2P}{$Y}{$X}} =  $X ;
	}

	foreach my $st ( $OldPos .. $NewPos-1 ) {
		my (@right, @pid);
		foreach my $X (sort { $a <=> $b } keys % { 	$m->{YX2P}{$Y} } ) {
			if ($X >= $OldPos) {
				push @right, $X;
				push @pid, $m->{YX2P}{$Y}{$X}
			}
		}
		for (my $i = 0; $i <= $#right; $i++) {
			my $X = $right[$i];
			my $P = $pid[$i];
			delete $m->{YX2P}{$Y}{$X};
			$X++;
			$m->{YX2P}{$Y}{$X} = $P;
			$m->{P2XY}{$P}{X}  = $X;
			if ($right[$i+1]) {
				last if $right[$i+1]-$X-1 >= $self->{FAM}{X_SPACE}{$fam}
			}
		}
	}
	return 1;
}


# calculate all line coordinates
#=============
sub SetLines {
#=============	
	my $fam = shift @_ || $self->{GLOB}{CURR_FAM};
	my $c = $canvas;	
	my $z = $self->{FAM}{ZOOM}{$fam};	
	my $d = $self->{FAM}{LINES}{$fam} = {};
	my $s = $self->{FAM}{STRUK}{$fam};
	my $gy = $self->{FAM}{GITTER_Y}{$fam};
	my $cf1 = $self->{FAM}{CROSS_FAKTOR1}{$fam};
	my $cd  = $self->{FAM}{CONSANG_DIST}{$fam};
	my $lsy = $self->{FAM}{LINE_SIBS_Y}{$fam};
	my $sz = $self->{FAM}{SYMBOL_SIZE}{$fam};
	my $lty = $self->{FAM}{LINE_TWINS_Y}{$fam};
	my $lcy = $self->{FAM}{LINE_CROSS_Y}{$fam};
	
	### calculate lines between parents			
	foreach my $parent_node (keys % { $self->{FAM}{PARENT_NODE}{$fam} }) {
		my ($par1, $par2) = @ { $self->{FAM}{PARENT_NODE}{$fam}{$parent_node} };
		
		### translate parents into "drawing compatible" order in case of multiple mates
		my ($par_t_1, $par_t_2) = TranslateCoupleGroup($fam, 'FROM_MATRIX', $par1, $par2);
		
		my @c1 = GetCanvasCoor($par_t_1,$fam);
		my @c2 = GetCanvasCoor($par_t_2,$fam);
								
		if ($c1[4]) { @c1[2,3] = @c1[4,5] }
		if ($c2[4]) { @c2[2,3] = @c2[4,5] }

		my (@X1, @X2);
		my ($x1, $x2);

		@X1 = @c1[0,2];
		@X2 = @c2[0,2];
								
		if ($X1[0] < $X2[0]) { ($x1, $x2) = ( $X1[1], $X2[0] ) }
		else { ($x1, $x2) = ( $X1[0], $X2[1] ) }

		my $xm1 = ($X1[0]+$X1[1])/2;
		my $xm2 = ($X2[0]+$X2[1])/2;
		
		### do not draw lines between couples up to the symbol middle point
		### to make possible the detection of symbol/line intersections 
		my $rr = $self->{FAM}{SYMBOL_SIZE}{$fam}*$z/4;
		if ($xm1 < $xm2) { $xm1 += $rr; $xm2 -= $rr }
		else { $xm1 -= $rr; $xm2 += $rr }
		
		my $ym1 = ($c1[1]+$c1[3])/2;
		my $ym2 = ($c2[1]+$c2[3])/2;								
		
		my $rd = ($xm2-$xm1)*$self->{FAM}{COUPLE_REL_DIST}{$fam};
		my $f = 2*$cd*$z; 
		
		### lines are stored as paths (end point one line = start point next line) for later drawing 
		### and also as single lines to count crosses : $d->{LINE_CROSS}
		
		### double line in case of consanguinity
		if (  ($self->{FAM}{LOOP}{$fam}{CONSANGUINE}{$par1} && $self->{FAM}{LOOP}{$fam}{CONSANGUINE}{$par1}{$par2}) ||
		($self->{FAM}{CONSANGUINE_MAN}{$fam}{$par1} && $self->{FAM}{CONSANGUINE_MAN}{$fam}{$par1}{$par2}) ) {
			
			### parents are at same y coordinates -> draw simple double line
			if ($ym1==$ym2) {									
				my $r = 
				[
					[ $xm1, $ym1-$cd*$z, $xm2, $ym2-$cd*$z ],
					[ $xm1, $ym1+$cd*$z, $xm2, $ym2+$cd*$z ]			 			
				];
				
				$d->{COUPLE}{$parent_node} = $r;								
				push  @ { $d->{LINE_CROSS} }, @$r
			}	
			### otherwise draw three double lines dependend on Y-axis location in two ways
			elsif ($ym1<$ym2) {
				$f *= -1 if $x1>$x2;
				$d->{COUPLE}{$parent_node} =
					[ 										
						[ $x1,$ym1-$cd*$z, $x1+$rd+$f, $ym1-$cd*$z ,$x1+$rd+$f, $ym2-$cd*$z ,$x2,$ym2-$cd*$z ],
						[ $x1,$ym1+$cd*$z, $x1+$rd,    $ym1+$cd*$z, $x1+$rd,    $ym2+$cd*$z, $x2,$ym2+$cd*$z ]
					];
					
				push @ { $d->{LINE_CROSS} }, 
				(				
					[ $x1,        $ym1-$cd*$z, $x1+$rd+$f, $ym1-$cd*$z ],
					[ $x1+$rd+$f, $ym1-$cd*$z, $x1+$rd+$f, $ym2-$cd*$z ],
					[ $x1+$rd+$f, $ym2-$cd*$z, $x2,        $ym2-$cd*$z ],	
					[ $x1,     $ym1+$cd*$z, $x1+$rd, $ym1+$cd*$z ],
					[ $x1+$rd, $ym1+$cd*$z, $x1+$rd, $ym2+$cd*$z ],
					[ $x1+$rd, $ym2+$cd*$z, $x2,     $ym2+$cd*$z ]
				)
			}
			else {
				$f *= -1 if $x1<$x2;
				$d->{COUPLE}{$parent_node} = 
				[
					[ $x2,$ym2-$cd*$z, $x2-$rd+$f, $ym2-$cd*$z, $x2-$rd+$f, $ym1-$cd*$z, $x1,$ym1-$cd*$z ],				
					[ $x2,$ym2+$cd*$z, $x2-$rd,    $ym2+$cd*$z ,$x2-$rd,    $ym1+$cd*$z ,$x1,$ym1+$cd*$z ]						
				];				
				push @ { $d->{LINE_CROSS} }, 
				( 										
					[ $x2,        $ym2-$cd*$z, $x2-$rd+$f, $ym2-$cd*$z ],
					[ $x2-$rd+$f, $ym2-$cd*$z, $x2-$rd+$f, $ym1-$cd*$z ],
					[ $x2-$rd+$f, $ym1-$cd*$z, $x1,        $ym1-$cd*$z ],	
					[ $x2,     $ym2+$cd*$z, $x2-$rd, $ym2+$cd*$z ],
					[ $x2-$rd, $ym2+$cd*$z, $x2-$rd, $ym1+$cd*$z ],
					[ $x2-$rd, $ym1+$cd*$z, $x1,     $ym1+$cd*$z ]
				)
			}
		}
				
		### no consanguinity --> draw only one line between parents (same cases as in consanguinity mode)
		else {
			if ($ym1==$ym2) {
				$d->{COUPLE}{$parent_node} = [ [ $x1, $ym1, $x2, $ym2 ] ];
				push  @ { $d->{LINE_CROSS} }, @ { $d->{COUPLE}{$parent_node} }
			}
			elsif ($ym1<$ym2) {
				$d->{COUPLE}{$parent_node} = 
				[ [ $x1,$ym1, $x1+$rd, $ym1 ,$x1+$rd, $ym2, $x2, $ym2 ]];
				
				push  @ { $d->{LINE_CROSS} }, 
				(
					[ $x1,     $ym1, $x1+$rd, $ym1 ],
					[ $x1+$rd, $ym1, $x1+$rd, $ym2 ],
					[ $x1+$rd, $ym2, $x2,     $ym2 ]
				)
			}
			else {
				$d->{COUPLE}{$parent_node} = 
				[[ $x2, $ym2, $x2-$rd, $ym2,$x2-$rd, $ym1 ,$x1, $ym1 ]];
				
				push  @ { $d->{LINE_CROSS} }, 
				(
					[ $x2,     $ym2, $x2-$rd, $ym2 ],
					[ $x2-$rd, $ym2, $x2-$rd, $ym1 ],
					[ $x2-$rd, $ym1, $x1,     $ym1 ]
				)
			}
		}
	}

	### calculate lines between sib groups (if not a single child)
	foreach my $parent_node (keys %{$d->{COUPLE}}) {
		my ($c1, $c2) = split '==', $parent_node;
		$d->{TWIN_LINES}{$parent_node} = [];
		my @children_org = keys %{$self->{FAM}{CHILDREN_COUPLE}{$fam}{$c1}{$c2}};
		my (%prtg, @children);    
		foreach (@children_org) {					
			### check if children  belong to twin groups
			### the code is not very pretty but works
			if ($self->{FAM}{SID2TWIN_GROUP}{$fam}{$_}) {				
				my $tg = $self->{FAM}{SID2TWIN_GROUP}{$fam}{$_};				
				### counterpart twins
				if (! $prtg{$tg}) {					
					my (%ch_twin,@cy_twin); 
					my @twins = keys % { $self->{FAM}{TWIN_GROUP2SID}{$fam}{$tg} }; 										
					### coordinates for all twins
					foreach my $twin (@twins) {
						my @co = GetCanvasCoor($twin,$fam);						
						if ($co[4]) { @co[2,3] = @co[4,5] }
						my $xm = sprintf("%1.3f", ($co[0]+$co[2])/2); 
						if ($ch_twin{$xm}) { $xm+= 0.001 }				
						my $ym = sprintf("%1.3f", ($co[1]+$co[3])/2);
						push @cy_twin, $ym;				
						$ch_twin{$xm}{YUP} = $ym-($sz/2*$z);
						$ch_twin{$xm}{YM} = $ym;						
					}
					
					### most upper Y coordinate
					@cy_twin = sort { $a <=> $b } @cy_twin;
					
					### middle x coordinate
					my @twins_x = sort { $a <=> $b } keys %ch_twin;
					my $xm = sprintf("%1.3f", ($twins_x[0]+$twins_x[-1])/2);
					
					### create array as reference storing needed coordinate information
					### for this twin group
					my $r = [ $xm, $cy_twin[0], \@twins, \%ch_twin];
					push @children, $r;					
					
					### mark twin group to process it only once
					$prtg{$tg} = 1
				}				
			}
			else {
				push @children, $_;
			}
		}
		
		if (scalar @children > 1) {
			
			my (@x, $yc, $y1, @cy, %ch, %prtg);
			my $r = $d->{SIB}{$parent_node} = [];

			### sort Y-coordinates 
			foreach my $ref (@children) {			
				if (! ref $ref) { 				 				
					my @co = GetCanvasCoor($ref,$fam);								 				
					if ($co[4]) { @co[2,3] = @co[4,5] }
					my $xm = sprintf("%1.3f", ($co[0]+$co[2])/2); 
					### work around to prevent overwriting children with same x coordinate
					if ($ch{$xm}) { $xm+= 0.001 }				
					my $ym = sprintf("%1.3f", ($co[1]+$co[3])/2);
					push @cy, $ym;					
					$ch{$xm}{YUP} = $co[1];
				}
				else {
					my ($xm, $ym) = @$ref;
					if ($ch{$xm}) { $xm+= 0.001 }
					push @cy, $ym;					
					$ch{$xm}{YUP} = $ym;
					$ch{$xm}{IS_TWIN} = $ref;
				}				 				
			}
											
			### Y- coordinate of horizontal		
			@cy = sort { $a <=> $b } @cy;
			my $y_up = $cy[0] - $lsy*$z;
			
			### X-coordinates sorted list of a child group
			my @child_x = sort { $a <=> $b } keys %ch;
												
			### left and right child
			my $K_F = shift @child_x;
			my $K_L = pop @child_x;	 
			
			### shorten the line if this child represent a twin group
			if ($ch{$K_F}{IS_TWIN}) { $ch{$K_F}{YUP} -= ($lty*$z) }
			if ($ch{$K_L}{IS_TWIN}) { $ch{$K_L}{YUP} -= ($lty*$z) }			
			
			### counting line crosses Y linker
			push  @ { $d->{LINE_CROSS} }, [ $K_F, $y_up, $K_L, $y_up ];			
															
			### most left child line + horizontal line + most right child line --> as path
			push @$r, [ $K_F, $ch{$K_F}{YUP},$K_F, $y_up, $K_L, $y_up, $K_L, $ch{$K_L}{YUP} ];
			
			### remaining children
			foreach my $xm (@child_x) {
				if ($ch{$xm}{IS_TWIN}) { $ch{$xm}{YUP} -= ($lty*$z)		}
				push @$r, [ $xm, $ch{$xm}{YUP}, $xm, $y_up ]
			}				
			
			### special case twin group -> add lines
			foreach my $child_x ($K_F, @child_x, $K_L) {
				### vertikal lines for cross check
				push  @ { $d->{LINE_CROSS} }, [ $child_x, $ch{$child_x}{YUP}, $child_x, $y_up ];			
				if ($ch{$child_x}{IS_TWIN}) {
					my ($x3, $y2, $cref, $href) = @{ $ch{$child_x}{IS_TWIN} };	
					my $y3 = $y2-($lsy*$z);				
					my $y4 = $y2-($lty*$z);				
					for ($x3, $y2, $y3, $y4) { $_ = sprintf("%1.3f", $_) }					
					my $r2 = $d->{TWIN_LINES}{$parent_node};				
					
					### connector line for every twin
					foreach my $twin (@$cref) {
						my @co = GetCanvasCoor($twin,$fam);		
						my $xm = sprintf("%1.3f", ($co[0]+$co[2])/2); 
						my $ym = sprintf("%1.3f", ($co[1]+$co[3])/2); 											
						my $xd = sprintf("%0.2f", $x3-$xm)+0;
						my $yd = ($ym-$y4);
						my $s = $sz/2*$z;
						my ($xp, $yp) = (0,$s);
						### calculate new start point for the angular lines at circle border
						if ($xd) {
							my $c = sqrt (($xd*$xd)+($yd*$yd));												
							my $f = $c/$s; $xp = $xd/$f; $yp = $yd/$f;					
						}																		
						push @$r2, [$xm+$xp, $ym-$yp, $x3, $y4];
						push @ { $d->{LINE_CROSS} }, [$xm+$xp, $ym-$yp, $x3, $y4];								
					}
					
					### extra middle line for monozygotic twins
					if ($self->{FAM}{SID2TWIN_TYPE}{$fam}{$cref->[0]} eq 'm') {						
						my @xsort = sort { $a <=> $b } keys %$href;						
						my $xs1 = ($xsort[0]+$x3)/2;
						my $ys1 = ($href->{$xsort[0]}{YM}+$y4)/2;
						my $xs2 = ($xsort[-1]+$x3)/2;
						my $ys2 = ($href->{$xsort[-1]}{YM}+$y4)/2;														
						push @$r2, [$xs1, $ys1, $xs2, $ys2];					
					}
				}				
			}																											
		}
		
		### save single childs for later queries
		else {
			if (! ref $children[0]) {
				my @co = GetCanvasCoor($children[0],$fam);				
				if ($co[4]) { @co[2,3] = @co[4,5] }
				$d->{CHILD}{$parent_node} = [ ($co[0]+$co[2])/2, $co[1] ]
			}
			else {
				### code for twins here
				$d->{CHILD}{$parent_node} = [ [ $children[0] ] ]
			}
		}
	}

	#### 3. calculate lines between parents and sibs
	foreach my $parent_node (keys %{$d->{COUPLE}}) {
		my $r1 = $d->{COUPLE}{$parent_node}[-1] or next;
		
		### most lower line between couples
		my ($x1, $x2, $y1) = ( $r1->[-4], $r1->[-2], $r1->[-3]);		
		($x1, $x2) = ($x2,$x1) if $x2<$x1;
		
		my ($xm1, $xd1) = ( ($x1+$x2)/2, $x2-$x1 );		
		for ($xm1, $xd1, $y1) { $_ = sprintf("%1.3f", $_) }
								
		### there is a sib group
		if ($d->{SIB}{$parent_node}) {
			my $r2 = $d->{SIB}{$parent_node}[0];			
			my ($x3, $x4, $y2) = ( $r2->[2], $r2->[4], $r2->[3] );
			
			($x3, $x4) = ($x4,$x3) if $x4<$x3;
			
			my ($xm2,$xd2) = ( ($x3+$x4)/2, $x4-$x3 );
			for ($xm2, $xd2, $y2) { $_ = sprintf("%1.3f", $_) }
								
			### splitting the group connector
			if ( ($x4 <= $xm1) || ($x3 >= $xm1) ) {			
				$d->{COUPLE_SIB}{$parent_node} = 
				[ [$xm1, $y1, $xm1, $y2-($cf1*$gy*$z),$xm2, $y2-($cf1*$gy*$z),$xm2, $y2] ];
				
				push  @ { $d->{LINE_CROSS} },	
				(
					[$xm1, $y1, $xm1, $y2-($cf1*$gy*$z)],
					[$xm1, $y2-($cf1*$gy*$z), $xm2, $y2-($cf1*$gy*$z)],
					[$xm2, $y2-($cf1*$gy*$z), $xm2, $y2]						
				);
			}

			### direct conection depending on group width
			else {
				if ( $xd1 <= $xd2  ) {
					$d->{COUPLE_SIB}{$parent_node} = [ [ $xm1, $y1, $xm1, $y2 ] ]
				} else {
					$d->{COUPLE_SIB}{$parent_node} = [ [ $xm2, $y1, $xm2, $y2 ] ]
				}
				push  @ { $d->{LINE_CROSS} }, @ { $d->{COUPLE_SIB}{$parent_node} };
			}
		}
		### single children
		elsif ($d->{CHILD}{$parent_node}) {
			### no twin group, regular children
			if (! ref $d->{CHILD}{$parent_node}[0]) {
				my ($x3, $y2) = ($d->{CHILD}{$parent_node}[0],  $d->{CHILD}{$parent_node}[1]);				
				### direct connection parent -> single child
				if ( ($x1 < $x3) && ($x2 > $x3) ) {
					$d->{COUPLE_SIB}{$parent_node} = [ [$x3,$y1,$x3,$y2] ];
					push  @ { $d->{LINE_CROSS} }, ([$x3,$y1,$x3,$y2]);
				}
				### split it
				else {
					my $y3 = $y2-($lsy*$z)+($sz/2*$z);
					$d->{COUPLE_SIB}{$parent_node} = [[ $xm1,$y1,$xm1,$y3,$x3,$y3,$x3,$y2 ]];					
					push  @{$d->{LINE_CROSS}},([$xm1,$y1,$xm1,$y3],[$xm1,$y3,$x3,$y3],[$x3,$y3,$x3,$y2])
				}												     	
      }
      else {
      	my $r = $d->{CHILD}{$parent_node}[0];
				my ($x3, $y2, $cref, $href) = @{$r->[0]};											
				my $y3 = $y2-($lsy*$z);				
				my $y4 = $y2-($lty*$z);				
				for ($x3, $y2, $y3, $y4) { $_ = sprintf("%1.3f", $_) }
			
				### direct connection parent -> single child
				if ( ($x1 < $x3) && ($x2 > $x3) ) {
					$d->{COUPLE_SIB}{$parent_node} = [ [ $x3, $y1, $x3, $y4 ] ];
					push  @ { $d->{LINE_CROSS} }, @ { $d->{COUPLE_SIB}{$parent_node} };
				}
				### split
				else {
					$d->{COUPLE_SIB}{$parent_node} = 
					[ [ $xm1, $y1, $xm1, $y3 ,$x3,  $y3 ,$x3,  $y4 ]	];
					
					push  @ { $d->{LINE_CROSS} },	
						(
							[ $xm1, $y1, $xm1, $y3 ],[$xm1, $y3, $x3,  $y3 ], [$x3,  $y3, $x3,  $y4 ]						
						)
				}
				
				my $r2 = $d->{TWIN_LINES}{$parent_node};				
				foreach my $twin (@$cref) {
					my @co = GetCanvasCoor($twin,$fam);		
					my $xm = sprintf("%1.3f", ($co[0]+$co[2])/2); 
					my $ym = sprintf("%1.3f", ($co[1]+$co[3])/2); 											
					my $xd = sprintf("%0.2f", $x3-$xm)+0;
					my $yd = ($ym-$y4);
					my $s = $sz/2*$z;
					my ($xp, $yp) = (0,$s);
					### calculate new start point for the angular lines at circle border
					if ($xd) {
						my $c = sqrt (($xd*$xd)+($yd*$yd));												
						my $f = $c/$s; $xp = $xd/$f;$yp = $yd/$f;									
					}																				
					push @$r2, [$xm+$xp, $ym-$yp, $x3, $y4];
					push @ { $d->{LINE_CROSS} }, [$xm+$xp, $ym-$yp, $x3, $y4];																	
				}	
				if ($self->{FAM}{SID2TWIN_TYPE}{$fam}{$cref->[0]} eq 'm') {						
					my @xsort = sort { $a <=> $b } keys %$href;						
					my $xs1 = ($xsort[0]+$x3)/2;
					my $ys1 = ($href->{$xsort[0]}{YM}+$y4)/2;
					my $xs2 = ($xsort[-1]+$x3)/2;
					my $ys2 = ($href->{$xsort[-1]}{YM}+$y4)/2;														
					push @$r2, [$xs1, $ys1, $xs2, $ys2];					
				}								  				   	
      }        			 
		}						
	}
	
	### special case -> parallel crossing line between two sib groups
	### upper one horizontal line to distinguish them
	foreach my $id1 (keys %{$d->{SIB}}) {
		my $A = $d->{SIB}{$id1}[0];
		my $C = $d->{COUPLE_SIB}{$id1}[0];
		foreach my $id2 (keys %{$d->{SIB}}) {
			my $B = $d->{SIB}{$id2}[0];
			next if $id1 eq $id2;
			next if ! ($A->[3] == $B->[3]);
			next if ! (($A->[2] < $B->[2]) && ($A->[4] > $B->[2])) ||
						(($B->[2] < $A->[2]) && ($B->[4] > $A->[2]));
						
			$A->[3] -= 6 * $z;
			$A->[5] -= 6 * $z;
			$C->[3] -= 6 * $z;
			$C->[5] -= 6 * $z if $C->[5];
			$C->[7] -= 6 * $z if $C->[7];
			@_ = @ {  $d->{SIB}{$id1} }; shift;
			$_->[3] -= 6 * $z foreach @_;		
		}
	}
		
}

#===================
sub CountLineCross {
#===================
	my $fam = shift @_ || $self->{GLOB}{CURR_FAM};		
	my $s = $self->{FAM}{LINES}{$fam}{LINE_CROSS};
	undef $self->{FAM}{CROSS_CHECK}{$fam};
	my $cr=0;
	my %DS;       
	     
	foreach my $r1 (@$s) {
		foreach my $r2 (@$s) {
			### do not compare same lines
			next if $r1 eq $r2;	
			### and do not count crosses of two lines that already have been counted
			$_ = join '_', sort ($r1,$r2);
			next if $DS{$_};
			$DS{$_}=1;						
			$cr += CrossCheck($fam,$r1,$r2);
		}
	}
	
	#### count symbols overlapping a line
	foreach my $r1 (@$s) {
		foreach my $pid (keys %{ $self->{FAM}{PID}{$fam}}) {
			my @co = GetCanvasCoor($pid,$fam);
			$cr += CrossCheck($fam,$r1, [@co]);
		}			
	}
	return $cr
}


### new alghorithm for detecting parallele or crossed line intersection 07/2008
#===============
sub CrossCheck {
#===============
	my ($fam, $r1, $r2) = @_;
	
	my $z = $self->{FAM}{ZOOM}{$fam};
	my ($ax,$ay, $bx,$by) = @$r1;
	my ($cx,$cy, $dx,$dy) = @$r2;
	my $de = $self->{FAM}{CROSS_CHECK}{$fam};
	
	### round values
	foreach ($ax,$ay, $bx,$by, $cx,$cy, $dx,$dy) { $_ = sprintf("%0.0f", $_) }
	
	
	my $rn = ($ay-$cy)*($dx-$cx) - ($ax-$cx)*($dy-$cy);
	my $rd = ($bx-$ax)*($dy-$cy) - ($by-$ay)*($dx-$cx);
	
	### Lines are parallel and unable to cross
	return 0 if $rd ==0 && $rn !=0;
		
	## Lines are parallel and able to cross
	if ($rd==0 && $rn==0) {		
		if ($ax == $bx) {
			($ay, $by) = sort { $a <=> $b } ($ay, $by);
			($cy, $dy) = sort { $a <=> $b } ($cy, $dy);
			
			if ( (($cy>=$ay) && ($cy<$by)) || (($ay>=$cy) && ($ay<$dy))  ) { 			
				push @ { $self->{FAM}{CROSS_CHECK}{$fam} }, [ $ax-(5*$z),$ay-(5*$z),$ax+(5*$z),$ay+(5*$z), -width => 1, -outline => '#c0c0c0', -fill => '#000000'  ];	
				return 1 
			}			
		}
		
		else {
			($ax, $bx) = sort { $a <=> $b } ($ax, $bx);
			($cx, $dx) = sort { $a <=> $b } ($cx, $dx);
			if ( (($cx>=$ax) && ($cx<$bx)) || (($ax>=$cx) && ($ax<$dx))  ) {				
				push @ {$self->{FAM}{CROSS_CHECK}{$fam} }, [ $ax-5*$z,$ay-5*$z,$ax+5*$z,$ay+5*$z, -width => 1, -outline => '#c0c0c0', -fill => '#000000' ];		
				return 1 
			}
		}
		return 0		
	}
	
	my $intersection_ab = $rn / $rd;
	return 0 if ($intersection_ab<=0) or ($intersection_ab>=1);
				
	my $sn = ($ay-$cy)*($bx-$ax) - ($ax-$cx)*($by-$ay);                   
	my $intersection_cd = $sn / $rd;                   
	
	return 0 if ($intersection_cd<=0) or ($intersection_cd>=1);	
	
	my $intersection_x = $ax + $intersection_ab*($bx-$ax);
	my $intersection_y = $ay + $intersection_ab*($by-$ay);
	push @ { $self->{FAM}{CROSS_CHECK}{$fam} }, [ $intersection_x-(5*$z),$intersection_y-(5*$z),$intersection_x+(5*$z),$intersection_y+(5*$z), -width => 1, -outline => '#000000', -fill => '#c0c0c0'  ];	
	return 1;	
}


# examination of all mates and recursive mates of mates of child $child
# the list of mates is represented as simple drawing order @S
#===============
sub SetCouples {
#===============	
	my ($fam,$child) = @_;
	my (@S, @D ,@D2, %P, $flag, %SAVE);
	
	## find everybody joined in couple group  
	foreach ( keys % { $self->{FAM}{COUPLE}{$fam}{$child} }) {		
		$P{$_} = 1  if ! $self->{FAM}{CHILDREN}{$fam}{$child}{$_}
	}
	W:while (1) {
		undef $flag;
		foreach my $p ( keys %P ) {
			foreach my $c ( keys % { $self->{FAM}{COUPLE}{$fam}{$p} }) {
				if (! $P{$c} && ! $self->{FAM}{CHILDREN}{$fam}{$p}{$c}) {
					$P{$c} = 1; $flag = 1
				}
			}
		}
		last W unless $flag
	}
	
	### @S is drawing order of multiple mates in string form as ( p1, p2, p3, p4 )
	@S = keys %P;			
	return $child unless @S;
	ChangeOrder(\@S);
	if ($param->{SORT_COUPLE_BY_GENDER}) {
		@_ = (); 
		foreach (@S) { push @_, $_ if $self->{FAM}{SID2SEX}{$fam}{$_} == 1 }
		foreach (@S) { push @_, $_ if $self->{FAM}{SID2SEX}{$fam}{$_} != 1 }
		@_ = reverse(@_) if $param->{SORT_COUPLE_BY_GENDER} == 2;
		@S = @_
	}
	
	
	### from @S derived order of couples for example (  [ p1, p3 ], [ p2, p3 ], [ p3, p4 ] )
	### list @S is screened for most right hand free mate
	foreach my $p1 (@S) {
		foreach my $p2 (@S) {
			next if $p1 eq $p2;
			if ($self->{FAM}{CHILDREN_COUPLE}{$fam}{$p1}{$p2} && ! $SAVE{$p1}{$p2} && ! $SAVE{$p2}{$p1}) {				
				push @D, [ $p1, $p2 ];
				$SAVE{$p1}{$p2} = 1;
			}
		}
	}
	
	### additionaly store mate order in respect of centering children corect
	if ($#S > 1) {
		foreach my $i (0 .. $#S-1) {
			push @D2, [ $S[$i], $S[$i+1] ];
		}
	}
	else { push @D2, [ $S[0], $S[1] ] }	
	return [ [ @S ] , [ @D ], [ @D2] ];
}




#=================
sub DuplicatePid {
#=================	
	my ($fam, $p, $mate) = @_;					

	my $ci = $self->{FAM}{CASE_INFO}{$fam}{PID};
	$self->{FAM}{LOOP}{$fam}{DUPLICATION_COUNTER}{$p}++;
	my $dupc = $self->{FAM}{LOOP}{$fam}{DUPLICATION_COUNTER}{$p} + 1;
	my $pn = "$p($dupc)";
	
	$self->{FAM}{DUPLICATED_PID}{$fam}{$p}{$pn} = 1;         
	$self->{FAM}{DUPLICATED_PID_ORIG}{$fam}{$pn} = $p;
		
	my $k1 = $p . '==' . $mate;
	my $k2 = $pn . '==' . $mate;
	
	my @children = keys % {$self->{FAM}{CHILDREN_COUPLE}{$fam}{$p}{$mate} };
	
	delete $self->{FAM}{COUPLE}{$fam}{$p}{$mate};
	delete $self->{FAM}{COUPLE}{$fam}{$p} unless keys % {$self->{FAM}{COUPLE}{$fam}{$p}} ;
	delete $self->{FAM}{COUPLE}{$fam}{$mate}{$p};
	delete $self->{FAM}{COUPLE}{$fam}{$mate} unless keys % {$self->{FAM}{COUPLE}{$fam}{$mate}} ;		
	delete $self->{FAM}{CHILDREN_COUPLE}{$fam}{$p}{$mate};
	delete $self->{FAM}{CHILDREN_COUPLE}{$fam}{$p} unless keys %{$self->{FAM}{CHILDREN_COUPLE}{$fam}{$p}};		
	delete $self->{FAM}{CHILDREN_COUPLE}{$fam}{$mate}{$p};
	delete $self->{FAM}{CHILDREN_COUPLE}{$fam}{$mate} unless keys %{$self->{FAM}{CHILDREN_COUPLE}{$fam}{$mate}};		
	delete $self->{FAM}{SIBS}{$fam}{$k1};
	
	foreach (@children) {			
		$self->{FAM}{SIBS}{$fam}{$k2}{$_} = 1;			
		$self->{FAM}{CHILDREN_COUPLE}{$fam}{$mate}{$pn}{$_} = 1;
		$self->{FAM}{CHILDREN_COUPLE}{$fam}{$pn}{$mate}{$_} = 1;
		
		if ($self->{FAM}{SID2SEX}{$fam}{$p} == 1) { $self->{FAM}{SID2FATHER}{$fam}{$_} = $pn }
		else { $self->{FAM}{SID2MOTHER}{$fam}{$_} = $pn }
				
		delete $self->{FAM}{CHILDREN}{$fam}{$p}{$_} if $self->{FAM}{CHILDREN}{$fam}{$p}{$_};
		$self->{FAM}{CHILDREN}{$fam}{$pn}{$_} = 1;
	}
		
	delete $self->{FAM}{CHILDREN}{$fam}{$p} unless keys % {$self->{FAM}{CHILDREN}{$fam}{$p}};
	
	$self->{FAM}{SID2SEX}{$fam}{$pn} = $self->{FAM}{SID2SEX}{$fam}{$p};
	$self->{FAM}{SID2AFF}{$fam}{$pn} = $self->{FAM}{SID2AFF}{$fam}{$p};
	$self->{FAM}{COUPLE}{$fam}{$mate}{$pn} = 1;
	$self->{FAM}{COUPLE}{$fam}{$pn}{$mate} = 1;
	$self->{FAM}{PID}{$fam}{$pn}=1;
	$self->{FAM}{IS_DECEASED}{$fam}{$pn} = $self->{FAM}{IS_DECEASED}{$fam}{$p} if $self->{FAM}{IS_DECEASED}{$fam}{$p};
	
	### the new person ist founder per se
	$self->{FAM}{FOUNDER}{$fam}{$pn} = 1;
		
	### add case info fields
	if (keys % { $ci->{$p} }) {
		foreach (keys % { $ci->{$p} }) { $ci->{$pn}{$_} = $ci->{$p}{$_} }		
	}
	
	my $pid_old_new = $ci->{$p}{'Case_Info_1'} . "($dupc)";
	$ci->{$pn}{Case_Info_1}	= $pid_old_new;
	$self->{FAM}{PID2PIDNEW}{$fam}{$pid_old_new} = $pn;
	
	if (keys % { $self->{FAM}{LOOP}{$fam}{CONSANGUINE}{$p} }) {
		@_ = keys % {$self->{FAM}{LOOP}{$fam}{CONSANGUINE}{$p} };
		foreach (@_) {
			$self->{FAM}{LOOP}{$fam}{CONSANGUINE}{$pn}{$_} = 1;
			$self->{FAM}{LOOP}{$fam}{CONSANGUINE}{$_}{$pn} = 1;
		}
	}
	
	$_ = join '==', nsort($p, $mate);
	delete $self->{FAM}{PARENT_NODE}{$fam}{$_};
	$_ = join '==', nsort($pn,$mate);
	$self->{FAM}{PARENT_NODE}{$fam}{$_} = [ $pn, $mate ];
	
}

#==============
sub LoopBreak {
#==============	
	my $fam = shift @_ || $self->{GLOB}{CURR_FAM};
	foreach (keys % { $self->{FAM}{BREAK_LOOP_OK}{$fam} }) {
		next unless $self->{FAM}{BREAK_LOOP_OK}{$fam}{$_};
		my @p = split '==', $_;
		foreach (@p) { delete $self->{FAM}{LOOP}{$fam}{DROP_CHILDREN_FROM}{$_} if $self->{FAM}{LOOP}{$fam}{DROP_CHILDREN_FROM}{$_} }
			
		ChangeOrder(\@p);
		if (scalar @p > 2) {				
			my $p = shift @p;
			L:foreach (@p) {
				if ($self->{FAM}{COUPLE}{$fam}{$p}{$_}) {
					@p = ($p, $_); 
					last L;
				}
			}				
		}
		$self->{FAM}{LOOP}{$fam}{BREAK}{$p[0]}{$p[1]} = 1		
	}
			
	foreach my $p (keys % { $self->{FAM}{LOOP}{$fam}{BREAK} }) {
		foreach my $mate (keys % { $self->{FAM}{LOOP}{$fam}{BREAK}{$p} }) {					
			DuplicatePid($fam, $p, $mate);
		}				
	}
	1;
}
