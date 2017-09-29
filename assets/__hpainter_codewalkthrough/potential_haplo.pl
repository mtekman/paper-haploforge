#The doIT sub explains the majority of the processing, and a scan through the file for references to gender, sex, or sid only yeilds conditions pertaining to twin and couple
#conditioning, there does not seem to be ANY reference to gender specific processing of haplotypes.
#
# I'm not quite convinced that this alone is the reason why the program bugs out on the the training set mentioned, but it could be due to missing Maternal and Paternal groups
# 


### codes for genotypes:
### I   : informative genotype
### NI-0: completely lost haplotype
### NI-1: unique lost genotype
### NI-2: genotype OK + 'by hand' declared as non-informative
### NI-3: genotype OK +  automatic declared as non-informative
#=========================
sub ShuffleFounderColors {
#=========================
	my $fam = shift @_ || $self->{GLOB}{CURR_FAM};
	return unless $fam;
	
	return unless $self->{FAM}{HAPLO}{$fam};
	return unless keys %{ $self->{FAM}{HAPLO}{$fam}{PID} };
			
	my $h = $self->{FAM}{HAPLO}{$fam}{PID};
	my $un = $self->{FAM}{HAPLO_UNKNOWN}{$fam};
	my $huc = $self->{FAM}{HAPLO_UNKNOWN_COLOR}{$fam};

	my @founder = keys %{$self->{FAM}{FOUNDER}{$fam}} or return undef;

	### clear all color information of founder bars
	foreach my $pid (keys %{$self->{FAM}{PID}{$fam}}) {
		next unless defined $h->{$pid};
		undef $h->{$pid}{M}{BAR} unless $h->{$pid}{M}{SAVE};
		undef $h->{$pid}{P}{BAR} unless $h->{$pid}{P}{SAVE};
	}

	### declare founder
	my $c = scalar @{ $self->{FAM}{MAP}{$fam}{MARKER} } ;
	foreach my $p (@founder) {
		if ( $h->{"$p"} ) {
			foreach my $m ( 'M' , 'P' ) {
				next unless $h->{$p}{$m};
				next if $h->{$p}{$m}{SAVE};  
				$h->{$p}{$m}{HIDE} = 0;
				my $co = sprintf("#%02x%02x%02x", int(rand(256)),int(rand(256)),int(rand(256)));
				my $flag; for ( 1 .. $c ) {
					my $al = $h->{"$p"}{$m}{TEXT}[$_-1];
					if ($al eq $un) {
						push @{$h->{"$p"}{$m}{BAR}}, [ 'NI-1', $co ]
					}
					else {
						push @{$h->{"$p"}{$m}{BAR}}, ['I', $co ] ; $flag = 1
					}
				}
				unless ($flag) {
					foreach (@{$h->{"$p"}{$m}{BAR}}) { @$_[0] = 'NI-0' }
				}
			}
		}
	}
	1;
}

# Processing haplotype blocks
#======================
sub ProcessHaplotypes {
#======================
	my $fam = shift @_ || $self->{GLOB}{CURR_FAM};
	return unless $fam;
	
	return unless $self->{FAM}{HAPLO}{$fam};
	return unless $self->{FAM}{HAPLO}{$fam}{PID};

	my $h = $self->{FAM}{HAPLO}{$fam}{PID};
	my $s = $self->{FAM}{STRUK}{$fam};
	
	### delete everything instaed of founder
	foreach my $pid (keys %{$self->{FAM}{PID}{$fam} }) {
		next if $self->{FAM}{FOUNDER}{$fam}{$pid};
		next unless defined $h->{$pid};
		undef $h->{$pid}{P}{BAR};
		undef $h->{$pid}{M}{BAR};
	}
		
	###  derive haplotype colors
	W:while (1) {
		my $flag = 0;
		F:foreach my $pid (keys %{$self->{FAM}{PID}{$fam}}) {
			next if $self->{FAM}{FOUNDER}{$fam}{$pid};
			next unless $h->{$pid};
			### still no haplotype derived
			if (! $h->{$pid}{P}{BAR} || ! $h->{$pid}{M}{BAR} ) {
				next if ! $h->{$pid}{M}{TEXT} || ! $h->{$pid}{P}{TEXT};
				
				### duplicate color information from duplicated pids
				if ($self->{FAM}{DUPLICATED_PID_ORIG}{$fam}{$pid}) {
					my $orig_pid = $self->{FAM}{DUPLICATED_PID_ORIG}{$fam}{$pid};					
					if ($h->{$orig_pid}{P}{BAR} && $h->{$orig_pid}{M}{BAR}) {
						foreach ( @ { $h->{$orig_pid}{P}{BAR} } ) { push @ { $h->{$pid}{P}{BAR} }, [ @$_ ] }
						foreach ( @ { $h->{$orig_pid}{M}{BAR} } ) { push @ { $h->{$pid}{M}{BAR} }, [ @$_ ] }					
						next;
					}
					else { next }										
				}							
				
				my ($p, $m) = ( $self->{FAM}{SID2FATHER}{$fam}{$pid}, $self->{FAM}{SID2MOTHER}{$fam}{$pid} );
				if ( $h->{$p}{P}{TEXT} && $h->{$p}{M}{TEXT} ) {
					if ( ! $h->{$p}{P}{BAR} || ! $h->{$p}{M}{BAR}) {  $flag = 1 }
					else {
						my $a = $h->{$pid}{P}{TEXT};
						### BARs + ALLELE from father
						my ($aa1, $aa2) = ( $h->{$p}{P}{TEXT}, $h->{$p}{M}{TEXT} );
						my ($ba1, $ba2) = ( $h->{$p}{P}{BAR},  $h->{$p}{M}{BAR} );
						$h->{$pid}{P}{BAR} = CompleteBar($fam,$a, $aa1, $ba1, $aa2, $ba2);												
					}
				} else {
					ShowInfo("The file seemes to be corrupted - missing haplotype for $pid ?\n",'error');
					delete $self->{FAM}{HAPLO}{$fam};
					delete $self->{FAM}{HAPLO}{$fam};
					return undef
					
				}

				if ( $h->{$m}{P}{TEXT} && $h->{$m}{M}{TEXT} ) {
					if (! $h->{$m}{P}{BAR} || ! $h->{$m}{M}{BAR}) {  $flag = 1 }
					else {
						my $b = $h->{$pid}{M}{TEXT};
						### BARs + ALLELE from mother
						my ($ba3, $ba4) = ( $h->{$m}{P}{BAR},  $h->{$m}{M}{BAR} );
						my ($aa3, $aa4) = ( $h->{$m}{P}{TEXT}, $h->{$m}{M}{TEXT} );
						$h->{$pid}{M}{BAR} = CompleteBar($fam,$b, $aa3, $ba3, $aa4, $ba4);
					}
				} else {
					ShowInfo("The file seemed to be corrupted - missing haplotype for $m ?\n",'error');

					delete $self->{FAM}{HAPLO}{$fam};
					return undef
				}
			}
		}
		last W unless $flag;
	}
	1;
}




























#===============
sub SetSymbols {
#===============	
	my $fam = shift @_ || $self->{GLOB}{CURR_FAM};
	my $m = $self->{FAM}{MATRIX}{$fam} or return;
	my $z = $self->{FAM}{ZOOM}{$fam};
	my $l = $self->{FAM}{SYMBOL_LINE_WIDTH}{$fam};
	my $lnc = $self->{FAM}{LINE_COLOR}{$fam};
	my $s = $param->{SHOW_GRID};
	my $slnc = $self->{FAM}{SYMBOL_LINE_COLOR}{$fam};
	my $f1 = $self->{FAM}{FONT1}{$fam};
	my $f2 = $self->{FAM}{FONT_INNER_SYMBOL}{$fam};
	my $f3 = $self->{FAM}{FONT_HEAD}{$fam};
	my $f4 = $self->{FAM}{FONT_PROBAND}{$fam};
	my $f5 = $self->{FAM}{FONT_MARK}{$fam}; 
	my $font1 = [ $f1->{FAMILY},$f1->{SIZE}*$z , $f1->{WEIGHT},$f1->{SLANT} ];
	my $font2 = [ $f2->{FAMILY},$f2->{SIZE}*$z , $f2->{WEIGHT},$f2->{SLANT} ];
	my $head1 = [ $f3->{FAMILY},$f3->{SIZE}*$z , $f3->{WEIGHT},$f3->{SLANT} ];
	my $font4 = [ $f4->{FAMILY},$f4->{SIZE}*$z , $f4->{WEIGHT},$f4->{SLANT} ];
	my $font5 = [ $f5->{FAMILY},$f5->{SIZE}*$z , $f5->{WEIGHT},$f5->{SLANT} ];
	my $as = $self->{FAM}{ALIVE_SPACE}{$fam};
	my $ci = $self->{FAM}{CASE_INFO}{$fam};
	my $as1 = $self->{FAM}{ADOPTED_SPACE1}{$fam};
	my $as2 = $self->{FAM}{ADOPTED_SPACE2}{$fam};
	my $de = $self->{FAM}{DRAW_ELEMENTS}{$fam}{CANVAS} = {};
	my $ab1 = $self->{FAM}{ARROW_SYM_DIST}{$fam};
	my $arl = $self->{FAM}{ARROW_LENGTH}{$fam};
	my $dist1 = $self->{FAM}{ARROW_DIST1}{$fam};
	my $dist2 = $self->{FAM}{ARROW_DIST2}{$fam};
	my $dist3 = $self->{FAM}{ARROW_DIST3}{$fam};				
	my $plw = $self->{FAM}{ARROW_LINE_WIDTH}{$fam};
	my $plc = $self->{FAM}{ARROW_COLOR}{$fam};
	my $sz = $self->{FAM}{SYMBOL_SIZE}{$fam}/2;
	my $slcs = $self->{FAM}{SYMBOL_LINE_COLOR_SET}{$fam};
	my %t= (qw/0 u 1 m 2 f/);
	my %save;
	
	### adapt Y achsis of drawing elements dependent of haplotypes and drawing style
	CanvasTrimYdim();
	
	### Title		
	if (! $self->{FAM}{TITLE_X}{$fam}) {  
		($_) = sort { $a <=> $b } keys %{$m->{YX2P}} or return;
		@_ = sort { $a <=> $b } keys % { $m->{YX2P}{$_} } or return;
		$self->{FAM}{TITLE_X}{$fam} = ($_[0]+$_[-1])/2;
		$self->{FAM}{TITLE_Y}{$fam} = $_-3;
	}	
	
	if ($self->{FAM}{SHOW_HEAD}{$fam} ) {	 					
		if (! $self->{FAM}{TITLE}{$fam}) {  $self->{FAM}{TITLE}{$fam} = "Family $fam" }				
		push @ { $de->{TITLE} }, [
			$self->{FAM}{TITLE_X}{$fam}*$self->{FAM}{GITTER_X}{$fam}*$z, $self->{FAM}{TITLE_Y}{$fam}*$self->{FAM}{GITTER_Y}{$fam}*$z, 			
			-anchor => 'center', -text => $self->{FAM}{TITLE}{$fam} , 
			-font => $head1, -fill => $self->{FAM}{FONT_HEAD}{$fam}{COLOR}, -tags => [ 'TEXT' , 'HEAD', 'TAG' ]
		];		
	}
		
	### Zeichnen aller Personen-bezogenen Elemente
	### Drawing of individual related elements	
	foreach my $Y (keys % { $m->{YX2P} }) {
		foreach my $X (keys % { $m->{YX2P}{$Y} }) {
			my $p = $m->{YX2P}{$Y}{$X};
			if ($save{$p}) {next}
			$save{$p} = 1;
			my ($sex, $aff) = ( $self->{FAM}{SID2SEX}{$fam}{$p}, $self->{FAM}{SID2AFF}{$fam}{$p} );				
			my ($cx, $cy) = ($X*$self->{FAM}{GITTER_X}{$fam}, $Y*$self->{FAM}{GITTER_Y}{$fam});
			my $col = $self->{FAM}{AFF_COLOR}{$fam}{$aff};
			my $slnc_new = $col;
			if ($col eq '#ffffff') { $slnc_new = $slnc }
			elsif ($slcs) { $slnc_new= $slnc }
			
			### stillbirth
			if ($self->{FAM}{IS_SAB_OR_TOP}{$fam}{$p}) {								
				push @ { $de->{SYM_STILLBIRTH} }, [
					($cx-$sz)*$z, $cy*$z,
					$cx*$z, ($cy-$sz)*$z,
					($cx+$sz)*$z, $cy*$z,
					-width => $l*$z, -outline => $slnc_new,-fill => $col, -tags => [ 'SYMBOL', "SYM-$p", 'TAG' ]
				];		
			}
							
			### male
			elsif ($sex == 1) {
				push @ { $de->{SYM_MALE} }, [
					($cx-$sz)*$z, ($cy-$sz)*$z,
					($cx+$sz)*$z, ($cy+$sz)*$z ,
					-width => $l*$z, -outline => $slnc_new, -fill => $col, -tags => [ 'SYMBOL', "SYM-$p" , 'TAG' ] 
				];																				
			}
			### female
			elsif ($sex == 2) {				
				push @ { $de->{SYM_FEMALE} }, [
					($cx-$sz)*$z, ($cy-$sz)*$z,
					($cx+$sz)*$z, ($cy+$sz)*$z ,
					-width => $l*$z, -outline => $slnc_new, -fill => $col, -tags => [ 'SYMBOL', "SYM-$p", 'TAG' ]
				];						
			}
						
			### unknown gender
			else {
				push @ { $de->{SYM_UNKNOWN} }, [
					($cx-$sz*sqrt(2))*$z, $cy*$z,
					$cx*$z, ($cy-$sz*sqrt(2))*$z,
					($cx+$sz*sqrt(2))*$z, $cy*$z,
					$cx*$z, ($cy+$sz*sqrt(2))*$z,
					-width => $l*$z, -outline => $slnc_new,-fill => $col, -tags => [ 'SYMBOL', "SYM-$p", 'TAG' ]
				];		
			}			
		
			### show available text inside symbols if param: INNER_SYMBOL_TEXT is set.
			### for now disabled for SAB/TAP symbols because the inner space for that symbol
			### is to small to fit text properly
			if ($self->{FAM}{SHOW_INNER_SYBOL_TEXT}{$fam} && defined $self->{FAM}{INNER_SYMBOL_TEXT}{$fam}{$p} &&
				! $self->{FAM}{IS_SAB_OR_TOP}{$fam}{$p}) {
					push @ { $de->{INNER_SYMBOL_TEXT} },[
					$cx*$z, $cy*$z,
					-anchor => 'center', -text => $self->{FAM}{INNER_SYMBOL_TEXT}{$fam}{$p},
					-font => $font2, -fill => $self->{FAM}{FONT_INNER_SYMBOL}{$fam}{COLOR}, -tags => [ 'TEXT', "INNER_SYMBOL_TEXT-$p", 'INNER_SYMBOL_TEXT' ]
				];
			}
			
			### live status
			if ($self->{FAM}{IS_DECEASED}{$fam}{$p}) {				
				### spontaneous abort or termination of pregnancy
				### are calculated different
				if ($self->{FAM}{IS_SAB_OR_TOP}{$fam}{$p}) {
					push @ { $de->{LIVE_LINE} }, [						
						($cx-$sz)*$z, ($cy+($sz/2))*$z,
						($cx+($sz*3/4))*$z, ($cy-($sz/2)-($sz*3/4))*$z,																						
						-width => $l*$z,-fill => $lnc
					]					
				}			
				
				elsif (defined $self->{FAM}{INNER_SYMBOL_TEXT}{$fam}{$p}) {
					
					my $f = $sz/sqrt(2);
					my ($x1,$y1,$x2,$y2);
					my $as_i = 3;														
					
					if ($sex==1) {
						($x1, $y1) = ($cx-$sz,$cy+$sz);
						($x2, $y2) = ($cx+$sz,$cy-$sz);
					}
					elsif (!$sex || $sex==2) {
						($x1, $y1) = ($cx-$f,$cy+$f);
						($x2, $y2) = ($cx+$f,$cy-$f);
					}
					
					push @ { $de->{LIVE_LINE} }, [
						($x1-$as)*$z,   ($y1+$as)*$z ,
						($x1+$as_i)*$z, ($y1-$as_i)*$z ,
						-width => $l*$z,-fill => $lnc
					];
					
					push @ { $de->{LIVE_LINE} }, [
						($x2+$as)*$z,   ($y2-$as)*$z ,
						($x2-$as_i)*$z, ($y2+$as_i)*$z ,
						-width => $l*$z,-fill => $lnc	
					];
											
				} else {
					push @ { $de->{LIVE_LINE} }, [
						($cx-$sz-$as)*$z, ($cy+$sz+$as)*$z ,
						($cx+$sz+$as)*$z, ($cy-$sz-$as)*$z ,
						-width => $l*$z,-fill => $lnc
					]
				}
			}
			          
			### Individual identifier and case information
			foreach my $col ( 1 .. 5 ) {
				if ($self->{FAM}{CASE_INFO_SHOW}{$fam}{$col} && $ci->{COL_TO_NAME}{$col}) {
					my $yp = ($cy+$sz)*$z + $f1->{SIZE}*$z + ($col-1)*$f1->{SIZE}*$z;
					my $name = $ci->{COL_TO_NAME}{$col};					
					next if ! defined $ci->{PID}{$p}{$name};
					my $y_pid = sprintf ("%0.0f",$yp+($f1->{SIZE}*$z)/2);
					
					push @ { $de->{CASE_INFO} }, [	
						$cx*$z,  $yp,
						-anchor => 'center', -text => $ci->{PID}{$p}{$name} ,
						-font => $font1, -fill => $f1->{COLOR}, -tags => [ 'TEXT', "TEXT-$p" ]
					];
				}
			}
			
			### Proband status fild
			if ($self->{FAM}{IS_PROBAND}{$fam}{$p}) {											
				my $x1 = ($cx-$sz-$ab1);
				my $y1 = ($cy+($sz/3));				
				$x1-= $ab1 if $self->{FAM}{IS_ADOPTED}{$fam}{$p};				
				my $x2 = $x1-$arl;
				my $y2 = $y1+$arl;
								
				push @ { $de->{ARROWS} }, [
					$x2*$z, $y2*$z, $x1*$z, $y1*$z, -width => $plw*$z,-fill => $plc, -arrow => 'last', -arrowshape => [ $dist1*$z, $dist2*$z, $dist3*$z]
				];
				
				push @ { $de->{PROBAND_TEXT} }, [	
						($x2*$z) - ($f4->{SIZE}*$z)/2,  $y2*$z,-anchor => 'center', 
						-text => $self->{FAM}{PROBAND_SIGN}{$fam} ,-font => $font4, -fill => $f4->{COLOR}
				]; 				
			}
			
			
			
			### Marked field
			if (defined $self->{FAM}{SIDE_SYMBOL_TEXT}{$fam}{$p}) {			
				push @ { $de->{MARK_TEXT} }, [											
					($cx-$sz-($f5->{SIZE}/1.5))*$z,  ($cy-$sz-($f5->{SIZE}/1.5))*$z,-anchor => 'center', 										
					-text => $self->{FAM}{SIDE_SYMBOL_TEXT}{$fam}{$p} ,-font => $font5, -fill => $f5->{COLOR}
				];				
			}
			
			### adopted
			if (defined $self->{FAM}{IS_ADOPTED}{$fam}{$p}) {		
				my @l1 = (
					$cx-$sz+$as2, $cy+$sz+$as1,$cx-$sz-$as1, $cy+$sz+$as1,
					$cx-$sz-$as1, $cy-$sz-$as1,$cx-$sz+$as2, $cy-$sz-$as1
				);				
				my @l2 = (
					$cx+$sz-$as2, $cy+$sz+$as1,$cx+$sz+$as1, $cy+$sz+$as1,
					$cx+$sz+$as1, $cy-$sz-$as1,$cx+$sz-$as2, $cy-$sz-$as1
				);						
				foreach (@l1, @l2) { $_*= $z }
				push @ { $de->{IS_ADOPTED} }, [ @l1, -width => $l*$z,-fill => $lnc ];
				push @ { $de->{IS_ADOPTED} }, [ @l2, -width => $l*$z,-fill => $lnc ];				
			}
			
			### show gender as text under sab
			if ($self->{FAM}{IS_SAB_OR_TOP}{$fam}{$p} && $self->{FAM}{SHOW_GENDER_SAB}{$fam}) {
				push @ { $de->{SAB_GENDER} }, [											
					$cx*$z,  ($cy+($f4->{SIZE}/1.5))*$z,-anchor => 'center', 										
					-text => $t{$sex} ,-font => $font4, -fill => $f4->{COLOR}
				];
				
			}
		}
	}
}
