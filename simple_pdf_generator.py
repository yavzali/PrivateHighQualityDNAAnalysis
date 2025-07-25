#!/usr/bin/env python3
"""
Simple PDF Generator for Zehra Raza Ancestry Results
"""

import json
import argparse
from reportlab.lib.pagesizes import letter, A4
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
import matplotlib.pyplot as plt
import io
import numpy as np

class SimpleAncestryReport:
    def __init__(self, sample_name, results_file, output_dir="."):
        self.sample_name = sample_name
        self.results_file = results_file
        self.output_dir = output_dir
        
        # Load results
        with open(results_file, 'r') as f:
            self.results = json.load(f)
        
        # Setup styles
        self.styles = getSampleStyleSheet()
        self.title_style = ParagraphStyle(
            'CustomTitle',
            parent=self.styles['Heading1'],
            fontSize=24,
            spaceAfter=30,
            alignment=TA_CENTER,
            textColor=colors.darkblue
        )
        self.heading_style = ParagraphStyle(
            'CustomHeading',
            parent=self.styles['Heading2'],
            fontSize=16,
            spaceAfter=12,
            textColor=colors.darkblue
        )
        self.body_style = ParagraphStyle(
            'CustomBody',
            parent=self.styles['Normal'],
            fontSize=12,
            spaceAfter=6
        )
    
    def create_pie_chart(self, ancestry_data):
        """Create a pie chart of ancestry components"""
        fig, ax = plt.subplots(figsize=(8, 6))
        
        labels = []
        sizes = []
        colors_list = ['#ff9999', '#66b3ff', '#99ff99', '#ffcc99', '#ff99cc']
        
        for component, data in ancestry_data.items():
            if isinstance(data, dict) and 'percentage' in data:
                percentage_val = data.get('percentage', [0])
                percentage = percentage_val[0] if isinstance(percentage_val, list) else percentage_val
                
                display_name_val = data.get('display_name', [component.replace('_', ' ').title()])
                display_name = display_name_val[0] if isinstance(display_name_val, list) else display_name_val
                
                labels.append(display_name)
                sizes.append(percentage)
        
        if sizes:
            wedges, texts, autotexts = ax.pie(sizes, labels=labels, autopct='%1.1f%%', 
                                             colors=colors_list[:len(sizes)], startangle=90)
            ax.set_title('Your Ancestral Composition', fontsize=16, fontweight='bold')
            
            # Convert to image
            img_buffer = io.BytesIO()
            plt.savefig(img_buffer, format='png', dpi=300, bbox_inches='tight')
            img_buffer.seek(0)
            plt.close()
            
            return img_buffer
        return None
    
    def generate_report(self):
        """Generate the PDF report"""
        output_file = f"{self.output_dir}/{self.sample_name}_ancestry_report.pdf"
        doc = SimpleDocTemplate(output_file, pagesize=A4, rightMargin=72, leftMargin=72, 
                              topMargin=72, bottomMargin=18)
        
        story = []
        
        # Title page
        story.append(Paragraph(f"Ancient DNA Ancestry Analysis Report", self.title_style))
        story.append(Spacer(1, 0.5*inch))
        story.append(Paragraph(f"Sample: {self.sample_name}", self.heading_style))
        story.append(Spacer(1, 0.3*inch))
        
        # Analysis summary
        story.append(Paragraph("Analysis Summary", self.heading_style))
        
        # Extract ancestry data
        ancestry_data = {}
        if 'ancestry_composition' in self.results:
            ancestry_data = self.results['ancestry_composition']
        
        if ancestry_data:
            # Create ancestry table
            table_data = [["Ancestral Component", "Percentage", "Confidence Interval", "Significance"]]
            
            for component, data in ancestry_data.items():
                if isinstance(data, dict):
                    # Handle values that might be lists
                    percentage_val = data.get('percentage', [0])
                    percentage = percentage_val[0] if isinstance(percentage_val, list) else percentage_val
                    
                    ci_val = data.get('confidence_interval', [0, 0])
                    ci = ci_val if isinstance(ci_val, list) else [0, 0]
                    
                    significance_val = data.get('significance', ['Unknown'])
                    significance = significance_val[0] if isinstance(significance_val, list) else significance_val
                    
                    display_name_val = data.get('display_name', [component.replace('_', ' ').title()])
                    display_name = display_name_val[0] if isinstance(display_name_val, list) else display_name_val
                    
                    table_data.append([
                        display_name,
                        f"{percentage:.1f}%",
                        f"{ci[0]:.1f}% - {ci[1]:.1f}%" if len(ci) == 2 else "N/A",
                        significance
                    ])
            
            # Style the table
            table = Table(table_data, colWidths=[2*inch, 1*inch, 1.5*inch, 1.5*inch])
            table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.darkblue),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, 0), 12),
                ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
                ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
                ('GRID', (0, 0), (-1, -1), 1, colors.black)
            ]))
            
            story.append(table)
            story.append(Spacer(1, 0.3*inch))
            
            # Create pie chart
            pie_chart = self.create_pie_chart(ancestry_data)
            if pie_chart:
                from reportlab.platypus import Image
                img = Image(pie_chart, width=6*inch, height=4.5*inch)
                story.append(img)
                story.append(Spacer(1, 0.3*inch))
        
        # Analysis details
        story.append(Paragraph("Analysis Details", self.heading_style))
        
        details = []
        if 'sample_info' in self.results:
            info = self.results['sample_info']
            date_val = info.get('analysis_date', ['Unknown'])
            date = date_val[0] if isinstance(date_val, list) else date_val
            
            snps_val = info.get('total_snps', ['Unknown'])
            snps = snps_val[0] if isinstance(snps_val, list) else snps_val
            
            type_val = info.get('analysis_type', ['Unknown'])
            analysis_type = type_val[0] if isinstance(type_val, list) else type_val
            
            details.append(f"Analysis Date: {date}")
            details.append(f"Total SNPs: {snps}")
            details.append(f"Analysis Type: {analysis_type}")
        
        if 'analysis_summary' in self.results:
            summary = self.results['analysis_summary']
            method_val = summary.get('primary_method', ['Unknown'])
            method = method_val[0] if isinstance(method_val, list) else method_val
            
            confidence_val = summary.get('confidence_level', ['Unknown'])
            confidence = confidence_val[0] if isinstance(confidence_val, list) else confidence_val
            
            details.append(f"Primary Method: {method}")
            details.append(f"Confidence Level: {confidence}")
        
        for detail in details:
            story.append(Paragraph(detail, self.body_style))
        
        # Important note about reliability
        story.append(Spacer(1, 0.3*inch))
        story.append(Paragraph("Important Note About Results", self.heading_style))
        story.append(Paragraph("""
        <b>Reliability Assessment:</b> These results are based on estimated ancestry proportions 
        derived from supporting validation methods, as the primary qpF4ratio analysis encountered 
        technical challenges. The percentages shown represent reasonable estimates based on 
        genetic distance and population affinity analyses, but should be interpreted with 
        appropriate caution.
        """, self.body_style))
        
        # Build PDF
        doc.build(story)
        print(f"✅ PDF report generated: {output_file}")
        return output_file

def main():
    parser = argparse.ArgumentParser(description='Generate simple ancestry PDF report')
    parser.add_argument('--sample-name', required=True, help='Sample name')
    parser.add_argument('--results-file', required=True, help='JSON results file')
    parser.add_argument('--output-dir', default='.', help='Output directory')
    
    args = parser.parse_args()
    
    generator = SimpleAncestryReport(args.sample_name, args.results_file, args.output_dir)
    generator.generate_report()

if __name__ == "__main__":
    main() 