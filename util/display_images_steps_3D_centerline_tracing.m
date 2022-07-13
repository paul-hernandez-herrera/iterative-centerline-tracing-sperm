function display_images_steps_3D_centerline_tracing(image_3d_stack, head_segmentation, head_positions,output_model, traces, trace_last_it)
        %just to show the outputs outputs
        %getting screen size
        h = figure('units','normalized','outerposition',[0 0 1 1]);
        
        tiledlayout(2,3, 'TileSpacing', 'normal', 'Padding', 'normal');
        
        %plot first figure
        %subplot(2,2,1)
        ax1 = nexttile;
        imshow(max(image_3d_stack,[],3)',[],'InitialMagnification','fit'); colorbar;
        title({'3D image stack' 'Maximum Intensity Projection (MIP)'}, 'fontsize',15);

        %subplot(2,2,1)
        ax2 = nexttile;
        imshow(log(normalizeVol(max(single(image_3d_stack),[],3)',1,255)),[],'InitialMagnification','fit'); colorbar;
        title({'Preprocessing MIP'}, 'fontsize',15);        

        %plot third figure
        %subplot(2,2,3)
        ax3 = nexttile;
        imshow(max(output_model,[],3)',[],'InitialMagnification','fit'); colorbar;
        title({'MESON flagellum´s prediction' '(probability MIP)'}, 'fontsize',15)            
        
        %plot second figure
        ax4 = nexttile;
        imshow(max(head_segmentation,[],3)',[],'InitialMagnification','fit'); colorbar;
        hold on;
        for i=1:size(head_positions,1)
            plot(head_positions(i,1),head_positions(i,2),'g*');
        end            
        title({'Head segmentation/detection MIP'}, 'fontsize',15); 
        
        %plot fourth figure
        %subplot(2,2,4)
        ax5 = nexttile;
        imshow(log(single(max(image_3d_stack,[],3)')+1),[],'InitialMagnification','fit'); colorbar;
        hold on;
        c = {'b' 'g'};
        for i=1:length(traces)
            
            for j=1:length(traces{i})
                plot(traces{i}{j}(:,1), traces{i}{j}(:,2), c{mod(j,2)+1}, 'LineWidth',5);                
            end

            if ~isempty(trace_last_it{i})
                plot(trace_last_it{i}(:,1), trace_last_it{i}(:,2), 'r', 'LineWidth',5);
            end
            if not(isempty(traces{i}))
                plot(traces{i}{1}(1,1), traces{i}{1}(1,2),'om', 'MarkerSize', 10, 'MarkerFaceColor','m');    
            end
        end
        title('iterative tracing', 'fontsize',15)

        %plot sixth figure
        %subplot(2,2,4)
        ax6 = nexttile;
        imshow(log(single(max(image_3d_stack,[],3)')+1),[],'InitialMagnification','fit'); colorbar;
        hold on;
        c = {'b' 'g'};
        for i=1:length(traces)
            
            for j=1:length(traces{i})
                plot(traces{i}{j}(:,1), traces{i}{j}(:,2), 'g', 'LineWidth',5);                
            end

            if not(isempty(traces{i}))
                plot(traces{i}{1}(1,1), traces{i}{1}(1,2),'om', 'MarkerSize', 10, 'MarkerFaceColor','m');    
            end
        end
        title('center-line tracing', 'fontsize',15)        
        
        colormap(ax1,gray)
        colormap(ax2,gray)
        colormap(ax3,jet)
        colormap(ax4,gray)
        colormap(ax5,gray)
        colormap(ax6,gray)
end