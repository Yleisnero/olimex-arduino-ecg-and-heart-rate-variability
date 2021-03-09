function filteredData = cascadeIIRNotchFilter(filterFrequency1, filterFrequency2, qFactor1, qFactor2, samplingFrequency, data)
    % Cascade two IIR Notch filter to remove multiple frequencies from a signal

    wo1 = filterFrequency1/(samplingFrequency/2);
    bw1 = wo1/qFactor1;
    [b1,a1] = iirnotch(wo1, bw1, qFactor1);

    wo2 = filterFrequency2/(samplingFrequency/2);
    bw2 = wo2/qFactor2;
    [b2,a2] = iirnotch(wo2, bw2, qFactor2);

    H1 = dfilt.df2t(b1,a1);
    H2 = dfilt.df2t(b2,a2);

    Hcas = dfilt.cascade(H1, H2);

    filteredData = filter(Hcas, data);
end

