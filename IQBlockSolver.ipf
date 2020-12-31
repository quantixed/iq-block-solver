#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later

////////////////////////////////////////////////////////////////////////
// Menu items
////////////////////////////////////////////////////////////////////////
Menu "Macros"
	"IQ Puzzle Solver", PuzzleSolver()
End

////////////////////////////////////////////////////////////////////////
// Master functions and wrappers
////////////////////////////////////////////////////////////////////////
Function PuzzleSolver()
	CleanSlate()
	MakeTheBlocks()
	GenerateOrientations()
	AllTheCombinations()
	RunTheSolver()
	DisplaySolutions()
	MakeTheLayouts("sol_", 4, 3, saveIt = 0)
End

////////////////////////////////////////////////////////////////////////
// Main functions
////////////////////////////////////////////////////////////////////////
Function MakeTheBlocks()
	// block 0
	Make/O/N=(2,4)/I block_0 = 1
	// block 1
	Make/O/N=(3,4)/I block_1 = 1
	block_1[1,2][1,2] = 0
	// block 2
	Make/O/N=(4,3)/I block_2 = 1
	block_2[0,1][2] = 0
	block_2[2,3][0] = 0
	// block 3
	Make/O/N=(3,4)/I block_3 = 1
	block_3[1,2][0] = 0
	block_3[1,2][3] = 0
	// block 4
	Make/O/N=(5,2)/I block_4 = 1
	block_4[0,1][1] = 0
	// block 5
	Make/O/N=(4,3)/I block_5 = 1
	block_5[2,3][0] = 0
	block_5[2,3][2] = 0
	// block 6
	Make/O/N=(3,4)/I block_6 = 1
	block_6[0,1][2,3] = 0
	// block 7
	Make/O/N=(3,3)/I block_7 = 1
	block_7[2][0] = 0
	
	return 0
End

Function GenerateOrientations()
	String wName,newName

	Variable i,j,k
	
	for(i = 0; i < 8; i += 1)
		wName = "block_" + num2str(i)
		Wave w = $wName
		
		for(j = 0; j < 4; j += 1)
			newName = "orient_" + num2str(i) + "_" + num2str(j)
			Duplicate/O w, $newName
			if(j == 1)
				ImageRotate/C/O $newName
			elseif(j == 2)
				ImageRotate/F/O $newName
			elseif(j == 3)
				ImageRotate/W/O $newName
			endif
		endfor
		ImageRotate/O/H w // flip it
		
		for(j = 0; j < 4; j += 1)
			newName = "orient_" + num2str(i) + "_" + num2str(j+4)
			Duplicate/O w, $newName
			if(j == 1)
				ImageRotate/C/O $newName
			elseif(j == 2)
				ImageRotate/F/O $newName
			elseif(j == 3)
				ImageRotate/W/O $newName
			endif
		endfor
	endfor
	// now get rid of identical shapes
	String wList, wNameJ, wNameK
	Variable nWaves
	
	for(i = 0; i < 8; i += 1)
		wList = WaveList("orient_" + num2str(i) + "_*",";","")
		nWaves = ItemsInList(wList)
		Wave/T tw = ListToTextWave(wList, ";")
		Make/O/FREE/N=(nWaves) delWave=0 // 0 means keep, 1 means delete
		
		for(j = 0; j < nWaves; j += 1)
			if(delWave[j] == 1)
				continue
			endif
			wNameJ = StringFromList(j,wList)
			Wave wj = $wNameJ
			
			for(k = 0; k < nWaves; k += 1)
				if (k <= j)
					continue
				endif
				if(delWave[k] == 1)
					continue
				endif
				wNameK = StringFromList(k,wList)
				Wave wk = $wNameK
				delWave[k] = MatrixCheck(wj,wk)
			endfor
		endfor
		DeleteWaves(tw,delWave)
	endfor
	// store a numeric wave with the total of each orientation for each block as a row
	Make/O/N=(8) numOrientW
	for(i = 0; i < 8; i += 1)
		wList = WaveList("orient_" + num2str(i) + "_*",";","")
		numOrientW[i] = ItemsInList(wList)
	endfor
	
	return 0
End

STATIC Function MatrixCheck(m0,m1)
	Wave m0,m1
	
	// are dimensions the same
	if(DimSize(m0,0) == DimSize(m1,0) && DimSize(m0,1) == DimSize(m1,1))
		MatrixOP/O/FREE tempMat = (m0 - m1) * (m0 - m1)
		if(sum(tempMat) == 0)
			return 1
		else
			return 0
		endif
	else
		return 0
	endif
End

STATIC Function DeleteWaves(textW, deleteW)
	Wave/T textW
	Wave deleteW
	
	Variable nRows = numpnts(textW)
	
	Variable i
	
	for(i = 0; i < nRows; i += 1)
		if(deleteW[i] == 1)
			KillWaves/Z $(textW[i])
		endif
	endfor
End

Function AllTheCombinations()
	WAVE/Z numOrientW
	Variable nRows
	nRows = numOrientW[0] * numOrientW[1] * numOrientW[2] * numOrientW[3]
	nRows = nRows * numOrientW[4] * numOrientW[5] * numOrientW[6] * numOrientW[7]
	Make/O/N=(nRows,8)/T permutationW
	Variable counter = 0
	String list0 = WaveList("orient_0_*",";","")
	String list1 = WaveList("orient_1_*",";","")
	String list2 = WaveList("orient_2_*",";","")
	String list3 = WaveList("orient_3_*",";","")
	String list4 = WaveList("orient_4_*",";","")
	String list5 = WaveList("orient_5_*",";","")
	String list6 = WaveList("orient_6_*",";","")
	String list7 = WaveList("orient_7_*",";","")
	
	
	Variable i0,i1,i2,i3,i4,i5,i6,i7
	
	for(i0 = 0; i0 < numOrientW[0]; i0 += 1)
		for(i1 = 0; i1 < numOrientW[1]; i1 += 1)
			for(i2 = 0; i2 < numOrientW[2]; i2 += 1)
				for(i3 = 0; i3 < numOrientW[3]; i3 += 1)
					for(i4 = 0; i4 < numOrientW[4]; i4 += 1)
						for(i5 = 0; i5 < numOrientW[5]; i5 += 1)
							for(i6 = 0; i6 < numOrientW[6]; i6 += 1)
								for(i7 = 0; i7 < numOrientW[7]; i7 += 1)
									permutationW[counter][0] = StringFromList(i0,list0)
									permutationW[counter][1] = StringFromList(i1,list1)
									permutationW[counter][2] = StringFromList(i2,list2)
									permutationW[counter][3] = StringFromList(i3,list3)
									permutationW[counter][4] = StringFromList(i4,list4)
									permutationW[counter][5] = StringFromList(i5,list5)
									permutationW[counter][6] = StringFromList(i6,list6)
									permutationW[counter][7] = StringFromList(i7,list7)
									counter += 1
								endfor
							endfor
						endfor
					endfor
				endfor
			endfor
		endfor
	endfor
End

Function RunTheSolver()
	AllPermutations(8)
	WAVE/Z allPermMat
	Variable nPerms = DimSize(allPermMat,1) // this is what order we will take the blocks in
	WAVE/Z/T permutationW
	Variable nOPerms = DimSize(permutationW,0) // this is the possible orientations of the blocks that we take
	// for each row in permutationW, we can try to place them in the grid in the order
	// specified in allPermMat. This is 5.28482e+09 different supercombinations
	Make/O/FREE/T/N=8 tempWNameW
	String wList
	Variable solutions = 0, counter = 0, skipped = 0, answerFound = 0
	Print "Starting search...", time()
	
	Variable i,j
	
	for(i = 0; i < nOPerms; i += 1)
		answerFound = 0
		for(j = 0; j < nPerms; j += 1)
			tempWNameW[] = permutationW[i][allPermMat[p][j]]
			if(CheckImpossible(tempWNameW[0],0) == 1 || CheckImpossible(tempWNameW[7],1) == 1)
				skipped += 1
				continue
			endif
			wfprintf wList, "%s;", tempWNameW
			Wave/WAVE wr = ListToWaveRefWave(wList,0)
			if(SolveIt(wr) == 1)
				WAVE/Z theCMat
				Duplicate/O theCMat, $("solution_" + num2str(solutions))
				Print "Solution:", solutions, "Iterations:", counter, "Skipped:", skipped, time()
				Print "Key:", wList
				solutions += 1
				answerFound = 1
			endif
			counter += 1
			if(answerFound == 1)
				i = ceil(i / 5039) * 5039 // next iteration will be a multiple of 5040
				break
			endif
		endfor
	endfor
End


STATIC Function AllPermutations(num)
	Variable num
	
	Variable i,nf=factorial(num)
	Make/O/N=(num)/FREE/I wave0 = p+1, waveA, waveB=p
	Make/O/N=(num,nf)/I allPermMat
	
	for(i = 0; i < nf; i += 1)
		waveA = wave0
		if(statsPermute(waveA,waveB,1) == 0)
			break
		endif
		allPermMat[][i+1] = waveA[p] - 1
	endfor
	allPermMat[][0] = p
end

STATIC Function CheckImpossible(wName,firstLast)
	String wName
	Variable firstLast
	
	String impossibleFirsts = "orient_1_2;orient_1_3;orient_2_1;orient_2_4;orient_3_2;orient_3_3;orient_4_1;orient_4_6;orient_5_2;orient_5_3;orient_6_1;orient_6_6;orient_7_3;"
	String impossibleLasts = "orient_1_0;orient_1_1;orient_2_1;orient_2_4;orient_3_0;orient_3_1;orient_4_3;orient_4_4;orient_5_0;orient_5_1;orient_6_3;orient_6_4;orient_7_1;"
	if(firstLast == 0 && WhichListItem(wName,impossibleFirsts) >= 0)
		return 1
	elseif(firstLast == 1 && WhichListItem(wName,impossibleLasts) >= 0)
		return 0
	endif
End

STATIC Function SolveIt(wrw)
	Wave/WAVE wrw
	// we have an 8 x 8 matrix
	Make/O/N=(8,8)/I theMat=0, tempMat=0
	Make/O/N=(8)/FREE waveCheckW = 0 // this tells us if the supercombination is done
	// we also need to store the solution. The tempMat/theMat pair use 1 or 0 to mark filled positions
	// we'll use integer representation of the blocks (i + 1) here
	Make/O/N=(8,8)/I theCMat=0, tempCMat=0
	Variable ww, hh, obj
	String wName
	
	Variable i,j,k
	
	for(i = 0; i < 8; i += 1)
		Wave w = wrw[i]
		ww = DimSize(w,1)
		hh = DimSize(w,0)
		wName = NameOfWave(w)
		obj = str2num(wName[7])
		
		for(j = 0; j < 7; j += 1) // row, limit is 7 to save a loop
			if(waveCheckW[i] == 1)
				break
			endif
			
			for(k = 0; k < 7; k += 1) // column, limit is 7 to save a loop
				if(theMat[j][k] != 0) // if the space is already filled
					continue
				endif
				if(j + hh - 1 > 7 || k + ww - 1 > 7) // if out of bounds go to next
					break
				endif
				// set tempMat to be the same as the last correct matrix
				tempMat[][] = theMat[p][q]
				tempMat[j, j + hh - 1][k, k + ww - 1] = theMat[p][q] + w[p - j][q - k]
				// set tempCMat to be the same as the last correct colour matrix
				tempCMat[][] = theCMat[p][q]
				tempCMat[j, j + hh - 1][k, k + ww - 1] += w[p - j][q - k] * (obj + 1)
				if(TestIt(tempMat) == 0)
					// update theMat to be the same as tempMat if no clashes found
					theMat[][] = tempMat[p][q]
					// update theMat to be the same as tempMat if no clashes found
					theCMat[][] = tempCMat[p][q]
					// mark block as done
					waveCheckW[i] = 1
					break
				else
					continue
				endif
			endfor
		endfor
		if(waveCheckW[i] == 0) // a block failed to be placed
			return 0
		endif
	endfor
	// if we got here it might mean we have a solution
	if(sum(waveCheckW) == 8 && sum(theMat) == 64)
		return 1
	else
		return 0
	endif
End

STATIC Function TestIt(w)
	Wave w
	Findvalue/I=2 w
	if(V_Value >= 0)
		return 1
	else
		return 0
	endif
End

STATIC Function MakeColorWave()
	Make/O/N=(9,3) colorWave
	colorWave[][0]= {0,34952,65535,0,53713,0,14135,18761,55255}
	colorWave[][1]= {0,11308,35980,23130,19789,31868,43433,7967,55512}
	colorWave[][2]= {0,39064,24929,50886,34181,41120,34181,39578,23130}
End

Function DisplaySolutions()
	MakeColorWave()
	WAVE/Z colorWave
	String wList = WaveList("solution*",";","")
	String wName, plotName
	Variable nImages = ItemsInList(wList)
	
	Variable i
	
	for(i = 0; i < nImages; i += 1)
		wName = StringFromList(i,wList)
		Wave w = $wName
		plotName = "sol_" + num2str(i)
		KillWindow/Z $plotName
		NewImage/HIDE=0/N=$plotName/S=0 w
		ModifyImage/W=$plotname $wName cindex=colorWave,minRGB=(0,0,0),maxRGB=(0,0,0)
	endfor
End

////////////////////////////////////////////////////////////////////////
// Utility functions
////////////////////////////////////////////////////////////////////////
Function CleanSlate()
	String fullList = WinList("*", ";","WIN:71")
	Variable allItems = ItemsInList(fullList)
	String name
	Variable i
 
	for(i = 0; i < allItems; i += 1)
		name = StringFromList(i, fullList)
		KillWindow/Z $name		
	endfor
	
	KillDataFolder/Z root:data:
		
	// Kill waves in root
	KillWaves/A/Z
	// Look for data folders and kill them
	DFREF dfr = GetDataFolderDFR()
	allItems = CountObjectsDFR(dfr, 4)
	for(i = 0; i < allItems; i += 1)
		name = GetIndexedObjNameDFR(dfr, 4, i)
		KillDataFolder $name		
	endfor
End

STATIC Function KillTheseWaves(wList)
	String wList
	Variable nWaves = ItemsInList(wList)
	String wName
	
	Variable i
	
	for(i = 0; i < nWaves; i += 1)
		wName = StringFromList(i, wList)
		Wave w0 = $wName
		KillWaves/Z w0
	endfor
End

STATIC Function MakeTheLayouts(prefix,nRow,nCol,[iter, filtVar, rev, alphaSort, saveIt, orient])
	String prefix
	Variable nRow, nCol
	Variable iter	// this is if we are doing multiple iterations of the same layout
	Variable filtVar // this is the object we want to filter for
	Variable rev // optional - reverse plot order
	Variable alphaSort // optional - do alphanumeric sort
	Variable saveIt
	Variable orient //optional 1 = landscape, 0 or default is portrait
	if(ParamIsDefault(filtVar) == 0)
		String filtStr = prefix + "_*_" + num2str(filtVar) + "_*"	// this is if we want to filter for this string from the prefix
	endif
	
	String layoutName = "all"+prefix+"Layout"
	DoWindow/K $layoutName
	NewLayout/N=$layoutName
	String allList = WinList(prefix+"*",";","WIN:1") // edited this line from previous version
	String modList = allList
	Variable nWindows = ItemsInList(allList)
	String plotName
	
	Variable i
	
	if(ParamIsDefault(filtVar) == 0)
		modList = "" // reinitialise
		for(i = 0; i < nWindows; i += 1)
			plotName = StringFromList(i,allList)
			if(stringmatch(plotName,filtStr) == 1)
				modList += plotName + ";"
			endif
		endfor
	endif
	
	if(ParamIsDefault(alphaSort) == 0)
		if(alphaSort == 1)
			modList = SortList(modList)
		endif
	endif
	
	nWindows = ItemsInList(modList)
	Variable PlotsPerPage = nRow * nCol
	String exString = "Tile/A=(" + num2str(ceil(PlotsPerPage/nCol)) + ","+num2str(nCol)+")"
	
	Variable pgNum=1
	
	for(i = 0; i < nWindows; i += 1)
		if(ParamIsDefault(rev) == 0)
			if(rev == 1)
				plotName = StringFromList(nWindows - 1 - i,modList)
			else
				plotName = StringFromList(i,modList)
			endif
		else
			plotName = StringFromList(i,modList)
		endif
		AppendLayoutObject/W=$layoutName/PAGE=(pgnum) graph $plotName
		if(mod((i + 1),PlotsPerPage) == 0 || i == (nWindows -1)) // if page is full or it's the last plot
			if(ParamIsDefault(orient) == 0)
				if(orient == 1)
					LayoutPageAction size(-1)=(842,595), margins(-1)=(18, 18, 18, 18)
				endif
			else
				// default is for portrait
				LayoutPageAction/W=$layoutName size(-1)=(595, 842), margins(-1)=(18, 18, 18, 18)
			endif
			ModifyLayout/W=$layoutName units=0
			ModifyLayout/W=$layoutName frame=0,trans=1
			Execute /Q exString
			if (i != nWindows -1)
				LayoutPageAction/W=$layoutName appendpage
				pgNum += 1
				LayoutPageAction/W=$layoutName page=(pgNum)
			endif
		endif
	endfor
	
	String fileName
	// if anthing is passed here we save an iteration, otherwise usual name
	if(!ParamIsDefault(iter))
		fileName = layoutName + num2str(iter) + ".pdf"
	else
		fileName = layoutName + ".pdf"
	endif
	// if anthing is passed here we save the filtered version
	if(ParamIsDefault(filtVar) == 0)
		fileName = ReplaceString(".pdf",fileName, "_" + num2str(filtVar) + ".pdf")
	endif
	if(ParamIsDefault(saveIt) == 0)
		if(saveIt == 1)
			SavePICT/O/WIN=$layoutName/PGR=(1,-1)/E=-2/W=(0,0,0,0) as fileName
		endif
	else
		// default is to save
		SavePICT/O/WIN=$layoutName/PGR=(1,-1)/E=-2/W=(0,0,0,0) as fileName
	endif
End