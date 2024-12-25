import 'dart:io';
import 'package:bar_sender/views/pdf_view.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw; // Update the path accordingly

class PdfGenerator {
  static Future<void> toPdfGen(BuildContext context, final String slipNumber, final String partyName, final String partyAddress, final String vehicleNumber,final String date, final String time, final List<List<String>> tableData) async {
    final pdf = pw.Document();

    final int firstPageChunkSize = 20; // Number of rows on the first page
    final int otherPagesChunkSize = 25; // Number of rows on other pages
    final List<String> header = ["S.no.", "Brand", "Size", "Color", "Weight(Kg)"];

    final List<List<String>> firstPageChunk = tableData.take(firstPageChunkSize).toList();
    final List<List<String>> remainingData = tableData.skip(firstPageChunkSize).toList();
    final List<List<List<String>>> chunks = chunkList(remainingData, otherPagesChunkSize);

    final String companyName = "Deepali Polyplast";
    final String companyAddress = "1234 Industrial Area, City, Country";


    final int totalBundles = tableData.length;
    final double totalWeight = tableData.fold(0.0, (sum, item) {
      final weight = double.tryParse(item[4]) ?? 0.0; // Assuming the weight is the 5th column
      return sum + weight;
    });

 
    // First page with company details
    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            buildHeader(companyName, companyAddress, slipNumber, partyName, partyAddress, vehicleNumber, date,time, true,totalBundles,totalWeight),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: header,
              data: firstPageChunk,
            ),
          ];
        },
      ),
    );

    // Remaining pages without company details
    for (var chunk in chunks) {
      pdf.addPage(
        pw.MultiPage(
          build: (pw.Context context) {
            return [
              buildHeader(companyName, companyAddress, slipNumber, partyName, partyAddress, vehicleNumber, date,time, false,0,0),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: header,
                data: chunk,
              ),
            ];
          },
        ),
      );
    }

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/table_report.pdf");
    await file.writeAsBytes(await pdf.save());

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => PDFScreen(path: file.path)),
    );
  }

  static pw.Widget buildHeader(
    String companyName,
    String companyAddress,
    String slipNumber,
    String partyName,
    String partyAddress,
    String vehicleNumber,
    String date,
    String time,
    bool isFirstPage,
    int totalBundles,
    double totalWeight,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (isFirstPage)
          pw.Column(
            children: [
              pw.Center(child: pw.Text(companyName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
              pw.Center(child: pw.Text(companyAddress, style: pw.TextStyle(fontSize: 12))),
              pw.SizedBox(height: 5),
            ],
          ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(children: [pw.Text("Slip No.: ", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)), pw.Text(slipNumber, style: pw.TextStyle(fontSize: 12)),pw.Spacer(),pw.Text("Date: ", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),pw.Text(date, style: pw.TextStyle(fontSize: 12))]),
            pw.Row(children: [pw.Text("Party Name: ", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)), pw.Text(partyName, style: pw.TextStyle(fontSize: 12)),pw.Spacer(),pw.Text("Time: ", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),pw.Text(time, style: pw.TextStyle(fontSize: 12))]),
            pw.Row(children: [pw.Text("Party Address: ", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)), pw.Text(partyAddress, style: pw.TextStyle(fontSize: 12))]),
            pw.Row(children: [pw.Text("Vehicle No.: ", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)), pw.Text(vehicleNumber, style: pw.TextStyle(fontSize: 12))]),
            pw.Divider(),
            if (isFirstPage)pw.Row(children: [pw.Text("Total Bundle.: "+totalBundles.toString(), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),pw.Spacer(),pw.Text("Total Weight.: "+totalWeight.toStringAsFixed(3)+" Kg", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))]),
            if (isFirstPage)pw.Divider(),
          ],
        ),
      ],
    );
  }

  static List<List<List<String>>> chunkList(List<List<String>> list, int chunkSize) {
    List<List<List<String>>> chunks = [];

    for (int i = 0; i < list.length; i += chunkSize) {
      if (i + chunkSize > list.length) {
        chunks.add(list.sublist(i, list.length));
      } else {
        chunks.add(list.sublist(i, i + chunkSize));
      }
    }

    return chunks;
  }
}
