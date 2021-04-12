program MHWTextureConverter;

{$mode objfpc}{$H+}
uses SysUtils, Classes, TypInfo, BaseUnix;

const
  MagicNumberTex = $00584554;
  MagicNumberDds = $20534444;
  WMagicNumberDds = '444453207C00000007100A00';
  WMagicNumberTex = '5445580010000000000000000000000002000000';
  CompressOption = '08104000';
  DX10FixedFlags = '03000000000000000100000000000000';
  TexFixedUnkn = '01000000000000000000000000000000FFFFFFFF0000000000000000';

{$scopedEnums on}
type
  TMhwTexFormat = (
    DXGI_FORMAT_UNKNOWN = 0,
    DXGI_FORMAT_R8G8B8A8_UNORM = 7,
    DXGI_FORMAT_R8G8B8A8_UNORM_SRGB = 9,//LUTs
    DXGI_FORMAT_R8G8_UNORM = 19,
    DXGI_FORMAT_BC1_UNORM = 22,
    DXGI_FORMAT_BC1_UNORM_SRGB = 23,
    DXGI_FORMAT_BC4_UNORM = 24,
    DXGI_FORMAT_BC5_UNORM = 26,
    DXGI_FORMAT_BC6H_UF16 = 28,
    DXGI_FORMAT_BC7_UNORM = 30,
    DXGI_FORMAT_BC7_UNORM_SRGB = 31
  );

const
  MhwTexFormatOrder: Array[1..11] of TMhwTexFormat = (
    TMhwTexFormat.DXGI_FORMAT_UNKNOWN,
    TMhwTexFormat.DXGI_FORMAT_R8G8B8A8_UNORM,
    TMhwTexFormat.DXGI_FORMAT_R8G8B8A8_UNORM_SRGB,
    TMhwTexFormat.DXGI_FORMAT_R8G8_UNORM,
    TMhwTexFormat.DXGI_FORMAT_BC1_UNORM,
    TMhwTexFormat.DXGI_FORMAT_BC1_UNORM_SRGB,
    TMhwTexFormat.DXGI_FORMAT_BC4_UNORM,
    TMhwTexFormat.DXGI_FORMAT_BC5_UNORM,
    TMhwTexFormat.DXGI_FORMAT_BC6H_UF16,
    TMhwTexFormat.DXGI_FORMAT_BC7_UNORM,
    TMhwTexFormat.DXGI_FORMAT_BC7_UNORM_SRGB
  );

  MhwTexFormatNames: Array[1..11] of String = (
    'DXGI_FORMAT_UNKNOWN',
    'DXGI_FORMAT_R8G8B8A8_UNORM',
    'DXGI_FORMAT_R8G8B8A8_UNORM_SRGB',
    'DXGI_FORMAT_R8G8_UNORM',
    'DXGI_FORMAT_BC1_UNORM',
    'DXGI_FORMAT_BC1_UNORM_SRGB',
    'DXGI_FORMAT_BC4_UNORM',
    'DXGI_FORMAT_BC5_UNORM',
    'DXGI_FORMAT_BC6H_UF16',
    'DXGI_FORMAT_BC7_UNORM',
    'DXGI_FORMAT_BC7_UNORM_SRGB'
  );

type
  TDxgiFormat = (
    DXGI_FORMAT_UNKNOWN,
    DXGI_FORMAT_R32G32B32A32_TYPELESS,
    DXGI_FORMAT_R32G32B32A32_FLOAT,
    DXGI_FORMAT_R32G32B32A32_UINT,
    DXGI_FORMAT_R32G32B32A32_SINT,
    DXGI_FORMAT_R32G32B32_TYPELESS,
    DXGI_FORMAT_R32G32B32_FLOAT,
    DXGI_FORMAT_R32G32B32_UINT,
    DXGI_FORMAT_R32G32B32_SINT,
    DXGI_FORMAT_R16G16B16A16_TYPELESS,
    DXGI_FORMAT_R16G16B16A16_FLOAT,
    DXGI_FORMAT_R16G16B16A16_UNORM,
    DXGI_FORMAT_R16G16B16A16_UINT,
    DXGI_FORMAT_R16G16B16A16_SNORM,
    DXGI_FORMAT_R16G16B16A16_SINT,
    DXGI_FORMAT_R32G32_TYPELESS,
    DXGI_FORMAT_R32G32_FLOAT,
    DXGI_FORMAT_R32G32_UINT,
    DXGI_FORMAT_R32G32_SINT,
    DXGI_FORMAT_R32G8X24_TYPELESS,
    DXGI_FORMAT_D32_FLOAT_S8X24_UINT,
    DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS,
    DXGI_FORMAT_X32_TYPELESS_G8X24_UINT,
    DXGI_FORMAT_R10G10B10A2_TYPELESS,
    DXGI_FORMAT_R10G10B10A2_UNORM,
    DXGI_FORMAT_R10G10B10A2_UINT,
    DXGI_FORMAT_R11G11B10_FLOAT,
    DXGI_FORMAT_R8G8B8A8_TYPELESS,
    DXGI_FORMAT_R8G8B8A8_UNORM,
    DXGI_FORMAT_R8G8B8A8_UNORM_SRGB,
    DXGI_FORMAT_R8G8B8A8_UINT,
    DXGI_FORMAT_R8G8B8A8_SNORM,
    DXGI_FORMAT_R8G8B8A8_SINT,
    DXGI_FORMAT_R16G16_TYPELESS,
    DXGI_FORMAT_R16G16_FLOAT,
    DXGI_FORMAT_R16G16_UNORM,
    DXGI_FORMAT_R16G16_UINT,
    DXGI_FORMAT_R16G16_SNORM,
    DXGI_FORMAT_R16G16_SINT,
    DXGI_FORMAT_R32_TYPELESS,
    DXGI_FORMAT_D32_FLOAT,
    DXGI_FORMAT_R32_FLOAT,
    DXGI_FORMAT_R32_UINT,
    DXGI_FORMAT_R32_SINT,
    DXGI_FORMAT_R24G8_TYPELESS,
    DXGI_FORMAT_D24_UNORM_S8_UINT,
    DXGI_FORMAT_R24_UNORM_X8_TYPELESS,
    DXGI_FORMAT_X24_TYPELESS_G8_UINT,
    DXGI_FORMAT_R8G8_TYPELESS,
    DXGI_FORMAT_R8G8_UNORM,
    DXGI_FORMAT_R8G8_UINT,
    DXGI_FORMAT_R8G8_SNORM,
    DXGI_FORMAT_R8G8_SINT,
    DXGI_FORMAT_R16_TYPELESS,
    DXGI_FORMAT_R16_FLOAT,
    DXGI_FORMAT_D16_UNORM,
    DXGI_FORMAT_R16_UNORM,
    DXGI_FORMAT_R16_UINT,
    DXGI_FORMAT_R16_SNORM,
    DXGI_FORMAT_R16_SINT,
    DXGI_FORMAT_R8_TYPELESS,
    DXGI_FORMAT_R8_UNORM,
    DXGI_FORMAT_R8_UINT,
    DXGI_FORMAT_R8_SNORM,
    DXGI_FORMAT_R8_SINT,
    DXGI_FORMAT_A8_UNORM,
    DXGI_FORMAT_R1_UNORM,
    DXGI_FORMAT_R9G9B9E5_SHAREDEXP,
    DXGI_FORMAT_R8G8_B8G8_UNORM,
    DXGI_FORMAT_G8R8_G8B8_UNORM,
    DXGI_FORMAT_BC1_TYPELESS,
    DXGI_FORMAT_BC1_UNORM,
    DXGI_FORMAT_BC1_UNORM_SRGB,
    DXGI_FORMAT_BC2_TYPELESS,
    DXGI_FORMAT_BC2_UNORM,
    DXGI_FORMAT_BC2_UNORM_SRGB,
    DXGI_FORMAT_BC3_TYPELESS,
    DXGI_FORMAT_BC3_UNORM,
    DXGI_FORMAT_BC3_UNORM_SRGB,
    DXGI_FORMAT_BC4_TYPELESS,
    DXGI_FORMAT_BC4_UNORM,
    DXGI_FORMAT_BC4_SNORM,
    DXGI_FORMAT_BC5_TYPELESS,
    DXGI_FORMAT_BC5_UNORM,
    DXGI_FORMAT_BC5_SNORM,
    DXGI_FORMAT_B5G6R5_UNORM,
    DXGI_FORMAT_B5G5R5A1_UNORM,
    DXGI_FORMAT_B8G8R8A8_UNORM,
    DXGI_FORMAT_B8G8R8X8_UNORM,
    DXGI_FORMAT_R10G10B10_XR_BIAS_A2_UNORM,
    DXGI_FORMAT_B8G8R8A8_TYPELESS,
    DXGI_FORMAT_B8G8R8A8_UNORM_SRGB,
    DXGI_FORMAT_B8G8R8X8_TYPELESS,
    DXGI_FORMAT_B8G8R8X8_UNORM_SRGB,
    DXGI_FORMAT_BC6H_TYPELESS,
    DXGI_FORMAT_BC6H_UF16,
    DXGI_FORMAT_BC6H_SF16,
    DXGI_FORMAT_BC7_TYPELESS,
    DXGI_FORMAT_BC7_UNORM,
    DXGI_FORMAT_BC7_UNORM_SRGB,
    DXGI_FORMAT_AYUV,
    DXGI_FORMAT_Y410,
    DXGI_FORMAT_Y416,
    DXGI_FORMAT_NV12,
    DXGI_FORMAT_P010,
    DXGI_FORMAT_P016,
    DXGI_FORMAT_420_OPAQUE,
    DXGI_FORMAT_YUY2,
    DXGI_FORMAT_Y210,
    DXGI_FORMAT_Y216,
    DXGI_FORMAT_NV11,
    DXGI_FORMAT_AI44,
    DXGI_FORMAT_IA44,
    DXGI_FORMAT_P8,
    DXGI_FORMAT_A8P8,
    DXGI_FORMAT_B4G4R4A4_UNORM,
    DXGI_FORMAT_P208,
    DXGI_FORMAT_V208,
    DXGI_FORMAT_V408,
    DXGI_FORMAT_SAMPLER_FEEDBACK_MIN_MIP_OPAQUE,
    DXGI_FORMAT_SAMPLER_FEEDBACK_MIP_REGION_USED_OPAQUE,
    DXGI_FORMAT_FORCE_UINT
  );

const
  TexWith4Bpp = [ TMhwTexFormat.DXGI_FORMAT_BC1_UNORM, TMhwTexFormat.DXGI_FORMAT_BC1_UNORM_SRGB, TMhwTexFormat.DXGI_FORMAT_BC4_UNORM ];
  TexWith16Bpp = [ TMhwTexFormat.DXGI_FORMAT_R8G8_UNORM ];
  TexOfNewDDS = [ TMhwTexFormat.DXGI_FORMAT_BC7_UNORM, TMhwTexFormat.DXGI_FORMAT_BC7_UNORM_SRGB, TMhwTexFormat.DXGI_FORMAT_BC6H_UF16 ];

function FormatTagMap(AFormat: TMhwTexFormat): String;
begin
  case AFormat of
    TMhwTexFormat.DXGI_FORMAT_R8G8B8A8_UNORM: result := 'R8G8B8A8_';
    TMhwTexFormat.DXGI_FORMAT_R8G8B8A8_UNORM_SRGB: result := 'SR8G8B8A8_';
    TMhwTexFormat.DXGI_FORMAT_R8G8_UNORM: result := 'R8G8_';
    TMhwTexFormat.DXGI_FORMAT_BC1_UNORM: result := 'DXT1L_';
    TMhwTexFormat.DXGI_FORMAT_BC1_UNORM_SRGB: result := 'BC1S_';
    TMhwTexFormat.DXGI_FORMAT_BC4_UNORM: result := 'BC4_';
    TMhwTexFormat.DXGI_FORMAT_BC5_UNORM: result := 'BC5_';
    TMhwTexFormat.DXGI_FORMAT_BC6H_UF16: result := 'BC6_';
    TMhwTexFormat.DXGI_FORMAT_BC7_UNORM: result := 'BC7L_';
    TMhwTexFormat.DXGI_FORMAT_BC7_UNORM_SRGB: result := 'BC7S_';
  else
    result := 'UNKN_'
  end;
end;

function FormatMagicMap(AFormat: TMhwTexFormat): String;
begin
  case AFormat of
    TMhwTexFormat.DXGI_FORMAT_UNKNOWN: result := 'UNKN';
    TMhwTexFormat.DXGI_FORMAT_BC1_UNORM: result := 'DXT1';
    TMhwTexFormat.DXGI_FORMAT_BC4_UNORM: result := 'BC4U';
    TMhwTexFormat.DXGI_FORMAT_BC5_UNORM: result := 'BC5U';
  else
    result := 'DX10'
  end;
end;

function TexToDxgiFormat(TexFormat: TMhwTexFormat): TDxgiFormat;
var
  TexFormatName: String;
  i: Integer;
begin
  i := 1;
  while ( (TexFormat <> MhwTexFormatOrder[i]) and (i < High(MhwTexFormatOrder)) ) do
    Inc(i);
  TexFormatName := MhwTexFormatNames[i];
  result := TDxgiFormat( GetEnumValue(TypeInfo(TDxgiFormat), TexFormatName) );
end;

function DxgiToTexFormat(DdsFormat: TDxgiFormat): TMhwTexFormat;
var
  DdsFormatName: String;
  i: Integer;
begin
  DdsFormatName := GetEnumName(TypeInfo(TDxgiFormat), Ord(DdsFormat));

  i := 1;
  while (i <= High(MhwTexFormatNames)) and (DdsFormatName <> MhwTexFormatNames[i]) do
    Inc(i);

  if i <= High(MhwTexFormatNames) then
    result := MhwTexFormatOrder[i]
  else
    result := TMhwTexFormat.DXGI_FORMAT_UNKNOWN;
end;

function StringToByteArray(hex: String): TBytes;
var
  i, len: Integer;
begin
  result := nil;

  len := Length(hex) div 2;
  SetLength(result, len);
  for i := 0 to len - 1 do
    result[i] := StrToInt('$' + Copy(hex, 2 * i + 1, 2));
end;

function IntToBytesLittle(val: LongInt; rpt: Integer = 1): TBytes;
var
  src, repeatsrc: TBytes;
  i: Integer;
begin
    SetLength(src, 4);
    src[3] := (val shr 24) and $ff;
    src[2] := (val shr 16) and $ff;
    src[1] := (val shr 8) and $ff;
    src[0] := val and $ff;

    if (rpt > 1) then begin
      SetLength(repeatsrc, rpt * 4);
      for i := 0 to rpt - 1 do begin
        repeatsrc[i * 4] := src[0];
        repeatsrc[i * 4 + 1] := src[1];
        repeatsrc[i * 4 + 2] := src[2];
        repeatsrc[i * 4 + 3] := src[3];
      end;
      result := repeatsrc;
      exit;
    end;
    result := src;
end;

procedure MainProc();
var
  fsRead, fsWrite: TFileStream;
  file_info : Stat;
  magicNumber, mipMapCount: Integer;
  width, height, cur_width, cur_height, maxWidth: Integer;
  format_type, offset, size: Integer;
  typeMagic, compresstype: String;
  ddsformat: TDxgiFormat;
  texformat, x: TMhwTexFormat;
  destPath, destOld: String;
  WMagicNumberHead, EmptyByte11,
  EmptyByte5, CompressOptionByte, 
  EmptyByte4, ArbNumByte, WTexSolid: TBytes;
  ddsflag, filetypecode, ddsformatint: Integer;
  isRaw, isFullWidth: Boolean;
  base_loc: Integer;
  i, j: Integer;
begin
  writeln('MHW Texture Converter');
  writeln('Convert between .tex and .dds texture formats.');
  writeln('');
  if (Paramcount = 0) then begin
    writeln('Usage: tex24dds [input-file ...]');
    writeln('');
    writeln('(press any key to quit)');
    readln();
    Exit;
  end;

  for i := 1 to paramCount() do
  begin
    if fpstat(ParamStr(i), file_info) <> 0 then begin
      writeln('ERROR: ' + ParamStr(i) + ' not found.');
      continue;
    end;

    if (file_info.st_size < $C0) then begin
      writeln('ERROR: ' + ParamStr(i) + ' is too small.');
      continue;
    end;

    if (ExtractFileExt(ParamStr(i)) = '.tex') then begin
      fsRead := TFilestream.Create(ParamStr(i), fmOpenRead);
      try
        magicNumber := fsRead.ReadDWord;
        if (magicNumber <> MagicNumberTex) then begin
          writeln('ERROR: ' + ParamStr(i) + ' is not a valid tex file.');
          continue;
        end;

        fsRead.Position := $14;
        mipMapCount := fsRead.ReadDWord;
        width := fsRead.ReadDWord;
        height := fsRead.ReadDWord;

        fsRead.Position := $24;
        format_type := fsRead.ReadDWord;

        fsRead.Position := $B8;
        offset := fsRead.ReadQWord;
        size := file_info.st_size - offset;
        fsRead.Position := offset;

        typeMagic := '';
        compresstype := '';
        ddsformat := TDxgiFormat.DXGI_FORMAT_UNKNOWN;
        texformat := TMhwTexFormat.DXGI_FORMAT_UNKNOWN;

        x := Low(TMhwTexFormat);
        for x in MhwTexFormatOrder do
        begin
          if (format_type = Ord(x)) then begin
            texformat := TMhwTexFormat(format_type);
            ddsformat := TexToDxgiFormat(texformat);
            typeMagic := FormatMagicMap(texformat);
            compresstype := FormatTagMap(texformat);
            break;
          end;
        end;

        if (texformat = TMhwTexFormat.DXGI_FORMAT_UNKNOWN) then begin
          writeln('ERROR: Unknown TEX format ' + IntToStr(format_type) + '. ' + ParamStr(i));
          continue;
        end;

        destPath := ChangeFileExt( compresstype + ExtractFileName(ParamStr(i)), '.dds' );
        destPath := ExtractFilePath(ParamStr(i)) + destPath;

        fsWrite := TFilestream.Create(destPath, fmCreate);
        try
          WMagicNumberHead := StringToByteArray(WMagicNumberDds);
          fsWrite.WriteBuffer( WMagicNumberHead[0], Length(WMagicNumberHead) );
          fsWrite.WriteBuffer( IntToBytesLittle(height)[0], 4 );
          fsWrite.WriteBuffer( IntToBytesLittle(width)[0], 4 );

          if (texformat in TexWith4Bpp) then
            //4bpp texture size
            fsWrite.Write( IntToBytesLittle(width * height div 2)[0], 4 )
          else if (texformat in TexWith16Bpp) then
            //16bpp texture size
            fsWrite.Write( IntToBytesLittle(width * height * 2)[0], 4 )
          else
            //8bpp texture size
            fsWrite.Write( IntToBytesLittle(width * height)[0], 4 );

          fsWrite.Write( IntToBytesLittle(1)[0], 4 );
          fsWrite.Write( IntToBytesLittle(mipMapCount)[0], 4 );

          EmptyByte11 := IntToBytesLittle(0, 11);
          fsWrite.Write( EmptyByte11[0], Length(EmptyByte11) );

          fsWrite.Write( IntToBytesLittle(32)[0], 4 );
          fsWrite.Write( IntToBytesLittle(4)[0], 4 );

          fsWrite.Write( PChar(typeMagic)[0], Length(typeMagic) );

          EmptyByte5 := IntToBytesLittle(0, 5);
          fsWrite.Write( EmptyByte5[0], Length(EmptyByte5) );

          CompressOptionByte := StringToByteArray(CompressOption);
          fsWrite.Write(CompressOptionByte[0], Length(CompressOptionByte) );

          EmptyByte4 := IntToBytesLittle(0, 4);
          fsWrite.Write( EmptyByte4[0], Length(EmptyByte4) );

          if (typeMagic = 'DX10') then begin
            fsWrite.Write( IntToBytesLittle(Ord(ddsformat))[0], 4 );
            ArbNumByte := StringToByteArray(DX10FixedFlags);
            fsWrite.Write( ArbNumByte[0], Length(ArbNumByte) );
          end;

          fsWrite.CopyFrom(fsRead, size);
        finally
          fsWrite.Free;
        end;
      finally
        fsRead.Free;
      end;
    end else
    if (ExtractFileExt(ParamStr(i)) = '.dds') then begin
      destPath := ChangeFileExt(ExtractFileName(ParamStr(i)), '.tex' );
      destPath := ExtractFilePath(ParamStr(i)) + destPath;

      if (FileExists(destPath) = True) then begin
        destOld := ChangeFileExt(destPath, '.old');
        if (FileExists(destOld) = True) then
          DeleteFile(destOld);
        RenameFile(destPath, destOld);
      end;

      fsRead := TFilestream.Create(ParamStr(i), fmOpenRead);
      try
        magicNumber := fsRead.ReadDWord;
        if (magicNumber <> MagicNumberDds) then begin
          writeln('ERROR: ' + ParamStr(i) + ' is not a valid dds file.');
          continue;
        end;

        fsRead.Position := $8;
        ddsflag := fsRead.ReadDWord;
        isRaw := (ddsflag and $8) = $8;
        height := fsRead.ReadDWord;
        width := fsRead.ReadDWord;

        fsRead.Position := $1C;
        mipMapCount := fsRead.ReadDWord;

        fsRead.Position := $54;
        filetypecode := fsRead.ReadDWord;

        fsRead.Position := $80;
        ddsformatint := fsRead.ReadDWord;
        ddsformat := TDxgiFormat(ddsformatint);

        case filetypecode of
          //DX10
          $30315844: begin
            texformat := DxgiToTexFormat(ddsformat);
            end;
          //DXT1
          $31545844: begin
            texformat := TMhwTexFormat.DXGI_FORMAT_BC1_UNORM;
            end;
          //BC4U
          $55344342: begin
            texformat := TMhwTexFormat.DXGI_FORMAT_BC4_UNORM;
            end;
          //ATI2 BC5U
          $55354342, $32495441: begin
            texformat := TMhwTexFormat.DXGI_FORMAT_BC5_UNORM;
            end;
          //Raw
          0: begin
            if isRaw then
              texformat := TMhwTexFormat.DXGI_FORMAT_R8G8B8A8_UNORM;
            end;
        else
          texformat := TMhwTexFormat.DXGI_FORMAT_UNKNOWN;
        end;

        if ((FormatMagicMap(texformat) = 'DX10') and not isRaw) then
          fsRead.Position :=  $94
        else
          fsRead.Position :=  $80;

        size := file_info.st_size - fsRead.Position;

        if (texformat = TMhwTexFormat.DXGI_FORMAT_UNKNOWN) then begin
          writeln('ERROR: Unsupported DDS format ' + IntToStr(filetypecode) + '. ' + ParamStr(i));
          readln();
          continue;
        end;

        fsWrite := TFilestream.Create(destPath, fmCreate);
        try
          WMagicNumberHead := StringToByteArray(WMagicNumberTex);
          fsWrite.WriteBuffer( WMagicNumberHead[0], Length(WMagicNumberHead) );
          fsWrite.WriteBuffer( IntToBytesLittle(mipMapCount)[0], 4 );
          fsWrite.WriteBuffer( IntToBytesLittle(height)[0], 4 );
          fsWrite.WriteBuffer( IntToBytesLittle(width)[0], 4 );
          fsWrite.WriteBuffer( IntToBytesLittle(1)[0], 4 );
          fsWrite.WriteBuffer( IntToBytesLittle(Ord(texformat))[0], 4 );

          WTexSolid := StringToByteArray(TexFixedUnkn);
          fsWrite.WriteBuffer( WTexSolid[0], Length(WTexSolid) );

          if (texformat in TexOfNewDDS) then
            fsWrite.WriteBuffer( IntToBytesLittle(1)[0], 4 )
          else
            fsWrite.WriteBuffer( IntToBytesLittle(0)[0], 4 );

          fsWrite.WriteBuffer( IntToBytesLittle(0, 4)[0], 16 );
          fsWrite.WriteBuffer( IntToBytesLittle(-1, 8)[0], 32 );
          fsWrite.WriteBuffer( IntToBytesLittle(width)[0], 4 );

          isFullWidth := isRaw or (texformat = TMhwTexFormat.DXGI_FORMAT_R8G8_UNORM);
          if isFullWidth then
            fsWrite.WriteBuffer( IntToBytesLittle(width)[0], 2 )
          else
            fsWrite.WriteBuffer( IntToBytesLittle(width div 2)[0], 2 );

          fsWrite.WriteBuffer( IntToBytesLittle(width)[0], 2 );
          fsWrite.WriteBuffer( IntToBytesLittle(0, 2)[0], 8 );

          if isFullWidth then
            fsWrite.WriteBuffer( IntToBytesLittle(width)[0], 2 )
          else
            fsWrite.WriteBuffer( IntToBytesLittle(width div 2)[0], 2 );

          fsWrite.WriteBuffer( IntToBytesLittle(width)[0], 2 );
          fsWrite.WriteBuffer( IntToBytesLittle(0, 2)[0], 8 );

          if isFullWidth then
            fsWrite.WriteBuffer( IntToBytesLittle(width)[0], 2 )
          else
            fsWrite.WriteBuffer( IntToBytesLittle(width div 2)[0], 2 );

          fsWrite.WriteBuffer( IntToBytesLittle(width)[0], 2 );
          fsWrite.WriteBuffer( IntToBytesLittle(0, 8)[0], 32 );

          cur_width := width;
          cur_height := height;

          base_loc := $b8 + mipMapCount * 8;

          for j := 0 to mipMapCount - 1 do begin
            fsWrite.WriteBuffer( IntToBytesLittle(base_loc)[0], 4 );
            fsWrite.WriteBuffer( IntToBytesLittle(0)[0], 4 );

            if isRaw then
              maxWidth := 2
            else
              maxWidth := 4;

            if (texformat in TexWith4Bpp) then
              base_loc := base_loc + cur_width * cur_height div 2
            else if (texformat in TexWith16Bpp) then
              base_loc := base_loc + cur_width * cur_height * 2
            else if (isRaw) then
              base_loc := base_loc + cur_width * cur_height * 4
            else
              base_loc := base_loc + cur_width * cur_height;

            cur_width := cur_width div 2;
            cur_height := cur_height div 2;

            if cur_width > maxWidth then
              cur_width := cur_width
            else
              cur_width := maxWidth;
            if cur_height > maxWidth then
              cur_height := cur_height
            else
              cur_height := maxWidth;
          end;

          fsWrite.CopyFrom(fsRead, size);
        finally
          fsWrite.Free;
        end;

      finally
        fsRead.Free;
      end;
    end else
    begin
      writeln('ERROR: ' + ParamStr(i) + ' - unsupported file format.');
      continue;
    end;

    writeln(ParamStr(i) + ' - ready');
  end;
  writeln('');
  writeln('Job is completed!');
end;

begin
  MainProc;
end.
