#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::More;

subtest 'test' => sub {
    my $data=  "3   4
                4   3
                2   5
                1   3
                3   9
                3   3";
    
    my $dist = findDistance($data);
    is($dist, 11, "sample distance");
};

subtest 'real' => sub{
    local $/ = undef;
    my $data = <DATA>;
    my $dist = findDistance($data);
    is($dist, 3714264, "real distance");
};

sub findDistance{
    my ($data) = @_;
    # get the lists
    my @arr;
    while($data =~ /(\d+)\s+(\d+)/g){
        push(@{$arr[0]}, $1);
        push(@{$arr[1]}, $2);
    }
    # sort the lists
    for(my $i=0;$i<@arr;$i++){
        $arr[$i] = [sort{ $a <=> $b } @{$arr[$i]}];
    }
    # generate the distance
    my $dist;
    my $num=scalar(@{$arr[0]});
    for(my $i=0;$i<$num;$i++){
        $dist += abs($arr[0][$i] - $arr[1][$i]);
    }
    return $dist;
}

__DATA__
12823   12823
74540   88907
37687   50218
83750   57255
43380   59171
25542   37895
82191   69869
93287   63605
20054   26570
21769   12823
77367   67099
16570   82288
26289   87436
80405   62160
38985   84570
33507   70651
78135   12823
29782   72675
52972   60020
37251   13360
86302   11091
55698   99302
11884   23170
14203   42793
86556   92216
92768   98887
23528   57963
76772   28514
96066   46571
29967   49394
45832   53891
71411   57963
82438   48120
40512   35506
19236   46571
48739   79955
40697   15914
32715   27573
23920   36285
86163   69869
71324   39817
94448   27540
70651   73871
60362   15914
63567   12823
43893   46571
92105   21816
98994   67099
53618   84742
24942   39565
29346   67184
32212   19642
54509   82050
23312   64628
63771   21691
38440   26724
21816   95925
71068   65860
14609   55618
72011   48120
76020   84229
48211   33989
96092   33989
36555   23920
22030   48211
36465   99481
88296   67099
36187   77758
83500   67485
65799   74354
46450   23920
86793   29963
50695   44098
65118   14670
32787   44098
21102   97142
92131   29662
43798   67099
93295   66944
56130   15566
24670   87249
90131   74584
41483   16531
23843   73292
74526   29963
55839   14212
94207   49334
61338   73170
31666   39565
66759   97543
29722   74520
22134   35306
19270   23920
27053   44098
45607   42425
86346   89135
34136   69485
39445   70651
68166   98707
56499   36545
12580   48211
64981   44098
90943   39974
80049   39565
77875   48990
54424   57426
81207   68150
34414   98023
79187   52901
79346   23869
21513   46571
15053   40401
71310   38780
93889   68025
12261   69729
57278   25004
72612   92105
34775   29963
38466   70408
66141   71462
33759   28157
23508   80622
22658   68025
46137   51837
74240   68025
46323   88730
29267   44098
61682   13360
16246   33989
64833   21816
73449   92615
62582   20616
29963   15914
37974   60020
17782   45096
82282   23920
15291   60020
83471   92371
51148   75901
28497   23861
93661   22470
52360   44098
19563   39565
49131   59613
82638   21691
71749   21634
73375   39565
22422   98262
96517   42860
16499   70651
99194   74365
81566   21816
91031   69001
39388   67099
13545   23920
11979   51219
61595   13636
34228   61662
55043   69869
95357   70397
37082   57426
37273   44706
42656   51161
92506   98779
41866   89323
35492   10452
42148   57426
59819   34819
78615   13427
48003   85632
48120   46571
23470   48211
92290   97410
78534   29963
72064   39565
69219   57426
92793   69278
57426   43882
39836   79670
39861   33989
32392   49744
55837   87513
87360   76393
62336   20641
10582   85481
72887   51687
57048   29021
63586   29963
34767   41921
66407   21691
45550   62286
17625   48345
10410   33482
64946   61098
87598   64264
16102   60485
14876   37318
23095   24531
86353   85448
73654   15914
22354   23329
41772   62251
69998   79585
44106   15400
28581   31886
34682   11345
43448   50338
26948   29963
82482   68276
54701   12823
18922   51687
64395   29985
43509   99202
19177   74365
71169   39565
50214   46571
32348   14042
71943   23920
47564   48211
84539   53239
28303   40447
80955   10137
82358   71499
17552   12823
60419   86898
56250   77850
71200   67409
43301   15914
23512   49536
13712   84205
98354   98887
63702   22888
75354   46571
24304   68025
99181   20195
41856   23920
48236   23920
30623   69869
24467   48962
40537   48211
91888   61088
70968   23920
23744   46571
56536   13360
94739   23339
65273   32896
49147   23040
55705   98887
15517   26570
82815   99647
63974   33989
98269   72091
65774   62028
86130   88830
47706   52189
88818   96935
99823   12836
58198   44429
71859   74365
18878   21691
29955   91508
72262   44098
79061   90293
71591   46571
69367   57426
26570   30757
78497   83175
61128   46571
66101   99459
10443   59613
29154   39565
68366   46799
94940   78937
21614   91666
47019   34953
29836   51687
97089   14752
31180   77674
18692   33989
34377   15914
16206   67099
19568   46858
82230   98833
36957   15914
11625   21816
89751   14670
88264   44098
73202   21816
21389   91653
94699   63019
30321   29963
22159   28581
76341   85552
20287   48211
75921   83341
88878   60020
78703   92672
34581   68025
31498   67099
37178   46571
50526   34670
15667   12823
48472   61917
68025   19843
18152   84990
92997   57426
45194   17337
35792   90923
43913   58323
72309   68025
77240   87169
89083   59613
82310   62531
12555   10424
98925   10257
74420   52083
24589   85673
34708   61492
85722   38721
62893   51687
21691   74365
73322   12823
11492   54857
12490   18361
13166   48211
88705   39565
67301   82886
72198   67099
24874   28002
76487   67099
62948   31200
59865   63220
53676   26314
92741   67099
20860   13360
88028   59613
45201   85967
23667   32896
10581   26570
77520   34819
84566   59613
51687   29963
19781   68938
97491   97700
47531   14042
68156   96185
73324   49536
78968   79510
21596   33989
15448   80613
31170   56186
87856   44899
16001   92938
30641   13360
20379   94681
34736   81157
53290   15914
72642   16629
59344   51437
68199   93242
52460   90743
55008   36367
17539   68234
46571   20804
23893   13360
10902   14670
71961   61714
47252   90538
34801   85443
54575   44098
88121   10292
78637   91423
39213   67915
98141   78421
57963   14042
98480   23920
71147   57422
43578   51687
31681   50491
33700   17355
66228   41600
78032   74365
88321   21816
42531   48660
26035   94016
60429   15939
91612   17451
58120   23920
89407   75901
51440   74365
74970   28186
27277   57157
27465   34087
46755   14042
61113   99926
48174   29963
92842   92627
37889   35772
46193   31448
17838   13360
41317   92105
91203   74595
56700   21841
92225   23685
14042   29963
28888   43645
42409   29963
43742   28322
47950   56420
60012   32357
22784   59353
56646   70651
71287   33989
67068   81828
56344   60024
84576   33771
55332   86106
39659   17918
15449   94351
18435   45157
29432   53238
15665   23920
32310   57963
12187   13426
91607   19931
56064   23200
19785   88382
59910   80963
66450   98887
82386   16004
18764   94352
65692   77191
84784   20164
62951   74365
99050   48120
45731   39696
48470   21816
39324   53921
94800   46976
68808   97405
82573   14670
47088   21691
13951   68025
27500   39776
84585   38027
69048   13360
27780   90293
80590   11936
55370   75925
23451   97204
27191   92346
26100   14670
90293   12505
50078   88870
19137   39565
27737   90293
22569   29963
48902   69869
36815   74365
24284   21816
98928   87900
70871   17597
35712   60185
89228   48211
94986   39565
76950   54205
40752   57426
85746   39829
47474   57121
83603   69971
49261   69869
44969   13360
16958   74365
59433   57963
71578   18842
94375   62791
99614   13360
89622   69869
51129   56771
11156   51276
78767   33989
63554   40385
45860   34819
15810   47662
74771   47240
35428   80330
30052   81082
18150   41916
68986   93799
34820   88196
50201   56619
22996   59613
56297   67099
99260   58078
64688   21816
55665   28824
97956   37259
47097   21691
58688   33107
79583   48120
55063   45256
31835   32896
15371   14670
27844   46413
18991   40292
44786   32306
52280   81741
65427   46740
33385   43108
50750   57509
74193   75901
37598   59014
57331   39565
27243   26144
51656   23277
42413   70530
96608   18903
36579   24670
63733   21090
84536   20737
79453   35604
30983   29016
94593   15346
79422   50694
82346   70651
53011   70651
65714   47190
60573   46571
51630   13153
38941   69869
89753   12823
42939   13360
60575   88841
82800   48120
57035   41389
87371   87900
64061   65441
69851   84299
98809   65624
59834   27020
18835   51900
33278   14048
36041   34994
89750   90878
33377   57426
71745   79525
37615   56520
22986   15914
78993   32234
98887   53280
91495   57476
55009   83614
65088   13360
61107   55377
86850   69869
24409   39565
41647   20300
30341   98013
13360   83709
94119   39786
60874   69563
94681   90293
12294   93733
31270   44098
67169   48120
69982   25424
82546   46331
45548   75901
68981   59613
56539   19459
46787   76063
41640   70651
17244   69785
76548   67707
80347   75901
84619   62909
65047   21816
32440   21816
19858   47222
93947   46571
34433   25060
59800   87922
87150   11813
61593   12823
45059   45597
50520   48120
43404   70651
89153   14042
75276   63196
73975   59613
34721   85100
27022   29317
95168   46178
10562   48211
87285   21048
85124   73523
47645   74365
40814   29963
17256   28745
36758   39144
81972   51687
42533   71291
80579   67961
62777   44098
33567   73871
55729   33616
46613   83768
73688   15914
89566   48120
77156   38783
28195   76020
55581   57426
89915   73871
20696   78053
65015   56772
72302   14042
91965   94445
23577   21814
22461   47256
90346   58704
64595   45253
56289   56251
31184   28040
47349   82756
54200   15914
12174   67099
73040   15914
62683   39298
97890   93681
21601   74323
50505   86613
54550   67099
66662   44098
40887   69869
41179   21691
73871   69869
99728   97754
86319   65104
28466   28968
30688   39565
14670   83817
30371   10006
48181   15914
76745   57426
49779   96138
89394   39565
75451   39454
55547   26570
44988   57122
84043   33579
93713   50715
31694   59613
72390   50633
71964   73871
22241   33767
18282   69869
17656   76562
38157   50300
81358   39565
34819   50804
45875   78072
94156   40549
14920   27935
82795   73906
80301   92362
30755   26231
28592   74531
91455   48120
31513   49437
44618   74365
48624   33714
85008   23920
69604   23920
10980   22705
74651   43754
93201   48180
54330   68025
33989   31277
72222   46571
76785   86114
69869   13360
31444   70651
58717   49312
64974   46571
18089   93072
22555   58689
38811   50986
49910   28581
57919   96399
18217   65989
78980   25085
27451   99626
78501   41132
19069   56502
75640   14042
87479   84318
41487   13360
70904   41282
21143   67099
86138   66970
87503   50453
22997   30279
71054   30416
55242   63291
24796   26570
30921   12193
73901   71881
78719   70651
73668   21644
40062   50325
35543   23920
55260   44098
13994   62561
86199   55342
19950   24292
84417   41010
84692   23359
72516   17950
73062   33989
42339   93099
11175   12823
72962   15914
87900   47702
86061   21816
87216   19093
23397   59613
30171   23605
68984   57537
40889   25577
72952   70651
14335   45810
45886   90293
93935   90169
26858   57426
58806   57426
88530   90854
51385   70651
82517   48120
17888   13360
33574   89201
38099   13453
35615   76655
40717   21691
92891   21816
10071   55881
24679   60020
64001   64186
50189   70651
75901   28208
19520   10579
57337   81798
15914   14670
55533   24670
74365   29963
96604   14822
95480   47666
45043   21816
64043   59798
36479   44719
39565   45563
30729   21816
19592   51687
26575   57426
96389   30827
70446   86987
18115   46908
36896   46571
46417   48146
28955   66308
95051   96077
93673   70651
78658   67099
75363   86412
59940   22584
40027   40113
38318   48120
50269   57426
25217   20768
69573   99624
53784   24670
17175   53310
70773   43530
89981   21816
17683   80473
10680   43906
88622   95505
56828   34115
71454   92105
59613   76020
93410   39537
30592   57426
15125   28581
85953   67099
79266   12823
49278   28786
12848   74190
63339   48120
50598   34834
16139   39353
77235   74365
78026   44098
47079   70651
56200   98726
47450   70651
25045   24670
91763   68025
67107   91601
49768   67099
10521   88700
16496   21816
51163   37436
57687   67871
95222   46855
43170   46745
97168   79787
71573   70165
56432   15604
25242   14670
46595   96449
32896   12823
48197   29963
75971   24670
28619   42517
94122   81320
87681   92105
60991   56609
71377   50018
61971   56175
57550   16562
57301   90293
27464   39627
83664   69869
71107   26421
61718   59613
87707   98887
11237   24670
26115   77368
20429   48211
56169   85808
69274   32416
70566   39565
47104   64253
17710   68025
92830   76162
56054   73660
16340   70651
10392   34986
62500   19456
99320   19994
56618   29963
42612   22192
37193   50294
67800   77943
57447   34819
42054   57426
81285   20316
56698   14042
60682   25485
94833   33989
11001   56123
13344   38104
26492   37666
77913   34819
27127   67099
89373   14670
84245   23275
93176   57426
75068   44098
64691   37231
74682   96693
50985   14670
22840   28581
65569   39692
49536   25963
47009   87650
56625   76613
49670   59613
98701   28404
90721   74642
90568   90293
34398   38135
40654   58061
55254   57426
30820   69869
42973   53638
79937   98595
19796   46811
39676   48211
51100   68621
49955   13124
26946   13360
58367   29193
94451   48120
86596   16163
15417   98887
49413   74365
67099   13360
68239   98887
71586   65467
86204   68483
64235   94569
63186   87472
17587   97916
99477   44436
92932   87900
79794   55739
45968   74365
97597   58915
18098   97117
22937   38639
62634   90293
60948   14042
42836   64451
22355   12823
91739   21816
64123   14670
64181   60020
33245   47506
77922   74118
84133   75901
48885   53070
70613   92283
83117   12823
58707   75350
12185   92946
60020   28566
14029   41875
18414   49550
60903   26570
87438   39565
65638   57325
88259   12823
99038   86394
68699   10243
21850   42389
62281   21542
87797   12690
63846   15367
64314   15223
52539   89174
83073   48187
26743   35622
52779   19988
32981   55779
51090   34819
39533   35299
44432   57426
31692   44098
25549   51846
92429   67099
99835   18335
44128   32196
88115   21691
39366   18923
61773   74286
45953   60436
43635   88029
18349   13511
72541   92837
97794   69329
64562   29954
44098   13984
93431   81159
74605   15914
79186   96684
47291   23920
37794   36179
33349   98887
79910   57426
67576   34819
11875   37633
94186   46273
32249   59613
31261   70651
29272   46571
86184   74545
73999   30507
72117   46571
62639   60020
83988   72916
56794   73328
15112   39680
71467   61678
44399   71302
45068   21816
51866   46571
53229   47539
78623   57963
40054   14670
41884   91788
35923   57772
22363   74365
71817   46571
40307   92314
38911   13095
72191   21857
91448   59613
60833   44098
48061   21816
31899   33989
